package Data::Sah::Compiler;

use 5.010;
#use Carp;
use Moo;
use experimental 'smartmatch';
use Log::Any qw($log);

with 'Data::Sah::Compiler::TextResultRole';

use Scalar::Util qw(blessed);

our $VERSION = '0.41'; # VERSION

has main => (is => 'rw');

# instance to Language::Expr instance
has expr_compiler => (
    is => 'rw',
    lazy => 1,
    default => sub {
        require Language::Expr;
        Language::Expr->new;
    },
);

sub name {
    die "BUG: Please override name()";
}

# literal representation in target language
sub literal {
    die "BUG: Please override literal()";
}

# compile expression to target language
sub expr {
    die "BUG: Please override expr()";
}

sub _die {
    my ($self, $cd, $msg) = @_;
    die join(
        "",
        "Sah ". $self->name . " compiler: ",
        "at schema:/", join("/", @{$cd->{spath} // []}), ": ",
        # XXX show (snippet of) current schema
        $msg,
    );
}

# form dependency list from which clauses are mentioned in expressions NEED TO
# BE UPDATED: NEED TO CHECK EXPR IN ALL ATTRS FOR THE WHOLE SCHEMA/SUBSCHEMAS
# (NOT IN THE CURRENT CLSET ONLY), THERE IS NO LONGER A ctbl, THE WAY EXPR IS
# STORED IS NOW DIFFERENT. PLAN: NORMALIZE ALL SUBSCHEMAS, GATHER ALL EXPR VARS
# AND STORE IN $cd->{all_expr_vars} (SKIP DOING THIS IS
# $cd->{outer_cd}{all_expr_vars} is already defined).
sub _form_deps {
    require Algorithm::Dependency::Ordered;
    require Algorithm::Dependency::Source::HoA;
    require Language::Expr::Interpreter::VarEnumer;

    my ($self, $cd, $ctbl) = @_;
    my $main = $self->main;

    my %depends;
    for my $crec (values %$ctbl) {
        my $cn = $crec->{name};
        my $expr = defined($crec->{expr}) ? $crec->{value} :
            $crec->{attrs}{expr};
        if (defined $expr) {
            my $vars = $main->_var_enumer->eval($expr);
            for (@$vars) {
                /^\w+$/ or $self->_die($cd,
                    "Invalid variable syntax '$_', ".
                        "currently only the form \$abc is supported");
                $ctbl->{$_} or $self->_die($cd,
                    "Unhandled clause specified in variable '$_'");
            }
            $depends{$cn} = $vars;
            for (@$vars) {
                push @{ $ctbl->{$_}{depended_by} }, $cn;
            }
        } else {
            $depends{$cn} = [];
        }
    }
    #$log->tracef("deps: %s", \%depends);
    my $ds = Algorithm::Dependency::Source::HoA->new(\%depends);
    my $ad = Algorithm::Dependency::Ordered->new(source => $ds)
        or die "Failed to set up dependency algorithm";
    my $sched = $ad->schedule_all
        or die "Can't resolve dependencies, please check your expressions";
    #$log->tracef("sched: %s", $sched);
    my %rsched = map
        {@{ $depends{$sched->[$_]} } ? ($sched->[$_] => $_) : ()}
            0..@$sched-1;
    #$log->tracef("deps: %s", \%rsched);
    \%rsched;
}

# since a schema can be based on another schema, we need to resolve to get the
# "base" type's handler (and collect clause sets in the process). for example:
# if pos_int is [int => {min=>0}], and pos_even is [pos_int, {div_by=>2}] then
# resolving pos_even will result in: ["int", [{min=>0}, {div_by=>2}], []]. The
# first element is the base type, the second is merged clause sets, the third is
# merged extras.
sub _resolve_base_type {
    require Scalar::Util;

    my ($self, %args) = @_;
    my $ns   = $args{schema};
    my $t    = $ns->[0];
    my $cd   = $args{cd};
    my $th   = $self->get_th(name=>$t, cd=>$cd);
    my $seen = $args{seen} // {};
    my $res  = $args{res} // [$t, [], []];

    $self->_die($cd, "Recursive dependency on type '$t'") if $seen->{$t}++;

    $res->[0] = $t;
    unshift @{$res->[1]}, $ns->[1] if keys(%{$ns->[1]});
    unshift @{$res->[2]}, $ns->[2] if $ns->[2];
    if (Scalar::Util::blessed $th) {
        $res->[1] = $self->main->_merge_clause_sets(@{$res->[1]});
        $res->[2] = $self->main->_merge_clause_sets(@{$res->[2]});
    } else {
        $self->_resolve_base_type(schema=>$th, cd=>$cd, seen=>$seen, res=>$res);
    }
    $res;
}

# generate a list of clauses in clsets, in order of evaluation. clauses are
# sorted based on expression dependencies and priority. result is array of
# [CLSET_NUM, CLAUSE] pairs, e.g. ([0, 'default'], [1, 'default'], [0, 'min'],
# [0, 'max']).
sub _get_clauses_from_clsets {
    my ($self, $cd, $clsets) = @_;
    my $tn = $cd->{type};
    my $th = $cd->{th};

    my $deps;
    ## temporarily disabled, expr needs to be sorted globally
    #if ($self->_clset_has_expr($clset)) {
    #    $deps = $self->_form_deps($ctbl);
    #} else {
    #    $deps = {};
    #}
    #$deps = {};

    my $sorter = sub {
        my ($ia, $ca) = @$a;
        my ($ib, $cb) = @$b;
        my $res;

        # dependency
        #$res = ($deps->{"$ca.$ia"} // -1) <=> ($deps->{"$cb.$ib"} // -1);
        #return $res if $res;

        # prio from clause definition
        my ($metaa, $metab);
        eval {
            $metaa = "Data::Sah::Type::$tn"->${\("clausemeta_$ca")};
        };
        if ($@) {
            for ($cd->{args}{on_unhandled_clause}) {
                my $msg = "Unhandled clause for type $tn: $ca ($@)";
                next if $_ eq 'ignore';
                next if $_ eq 'warn'; # don't produce multiple warnings
                $self->_die($cd, $msg);
            }
        }
        $metaa //= {prio=>50};
        eval {
            $metab = "Data::Sah::Type::$tn"->${\("clausemeta_$cb")};
        };
        if ($@) {
            for ($cd->{args}{on_unhandled_clause}) {
                my $msg = "Unhandled clause for type $tn: $cb";
                next if $_ eq 'ignore';
                next if $_ eq 'warn'; # don't produce multiple warnings
                $self->_die($cd, $msg);
            }
        }
        $metab //= {prio=>50};

        {
            $res = $metaa->{prio} <=> $metab->{prio};
            #$log->errorf("TMP:   sort1");
            last if $res;

            # prio from schema
            my $sprioa = $clsets->[$ia]{"$ca.prio"} // 50;
            my $spriob = $clsets->[$ib]{"$cb.prio"} // 50;
            $res = $sprioa <=> $spriob;
            #$log->errorf("TMP:   sort2");
            last if $res;

            # alphabetical order of clause name
            $res = $ca cmp $cb;
            #$log->errorf("TMP:   sort3");
            last if $res;

            # clause set order
            $res = $ia <=> $ib;
            #$log->errorf("TMP:   sort4");
            last if $res;

            $res = 0;
        }

        #$log->errorf("TMP:   sort [%s,%s] vs [%s,%s] = %s", $ia, $ca, $ib, $cb, $res);
        $res;
    };

    my @clauses;
    for my $i (0..@$clsets-1) {
        push @clauses, map {[$i, $_]}
            grep {!/\A_/ && !/\./} keys %{$clsets->[$i]};
    }

    my $res = [sort $sorter @clauses];
    #$log->errorf("TMP: sorted clauses: %s", $res);
    $res;
}

sub get_th {
    my ($self, %args) = @_;
    my $cd    = $args{cd};
    my $name  = $args{name};

    my $th_map = $cd->{th_map};
    return $th_map->{$name} if $th_map->{$name};

    if ($args{load} // 1) {
        no warnings;
        $self->_die($cd, "Invalid syntax for type name '$name', please use ".
                        "letters/numbers/underscores only")
            unless $name =~ $Data::Sah::type_re;
        my $main = $self->main;
        my $module = ref($self) . "::TH::$name";
        if (!eval "require $module; 1") {
            $self->_die($cd, "Can't load type handler $module".
                            ($@ ? ": $@" : ""));
        }

        my $obj = $module->new(compiler=>$self);
        $th_map->{$name} = $obj;
    }
    use experimental 'smartmatch';

    return $th_map->{$name};
}

sub get_fsh {
    my ($self, %args) = @_;
    my $cd    = $args{cd};
    my $name  = $args{name};

    my $fsh_table = $cd->{fsh_table};
    return $fsh_table->{$name} if $fsh_table->{$name};

    if ($args{load} // 1) {
        no warnings;
        $self->_die($cd, "Invalid syntax for func set name '$name', ".
                        "please use letters/numbers/underscores")
            unless $name =~ $Data::Sah::funcset_re;
        my $module = ref($self) . "::FSH::$name";
        if (!eval "require $module; 1") {
            $self->_die($cd, "Can't load func set handler $module".
                            ($@ ? ": $@" : ""));
        }

        my $obj = $module->new();
        $fsh_table->{$name} = $obj;
    }
    use experimental 'smartmatch';

    return $fsh_table->{$name};
}

sub init_cd {
    require Time::HiRes;

    my ($self, %args) = @_;

    my $cd = {};
    $cd->{args} = \%args;

    if (my $ocd = $args{outer_cd}) {
        # for checking later, because outer_cd might be autovivified to hash
        # later
        $cd->{_inner}       = 1;

        $cd->{outer_cd}     = $ocd;
        $cd->{indent_level} = $ocd->{indent_level};
        $cd->{th_map}       = { %{ $ocd->{th_map}  } };
        $cd->{fsh_map}      = { %{ $ocd->{fsh_map} } };
        $cd->{default_lang} = $ocd->{default_lang};
        $cd->{spath}        = [@{ $ocd->{spath} }];
    } else {
        $cd->{indent_level} = $cd->{args}{indent_level} // 0;
        $cd->{th_map}       = {};
        $cd->{fsh_map}      = {};
        # we use || here because in some env, LANG/LANGUAGE is set to ''
        $cd->{default_lang} = $ENV{LANG} || "en_US";
        $cd->{default_lang} =~ s/\..+//; # en_US.UTF-8 -> en_US
        $cd->{spath}        = [];
    }
    $cd->{_id} = Time::HiRes::gettimeofday(); # compilation id
    $cd->{ccls} = [];

    $cd;
}

sub check_compile_args {
    my ($self, $args) = @_;

    return if $args->{_args_checked}++;

    $args->{data_name} //= 'data';
    $args->{data_name} =~ /\A[A-Za-z_]\w*\z/ or $self->_die(
        {}, "Invalid syntax in data_name '$args->{data_name}', ".
            "please use letters/nums only");
    $args->{allow_expr} //= 1;
    $args->{on_unhandled_attr}   //= 'die';
    $args->{on_unhandled_clause} //= 'die';
    $args->{skip_clause}         //= [];
    $args->{mark_missing_translation} //= 1;
    for ($args->{lang}) {
        $_ //= $ENV{LANG} || $ENV{LANGUAGE} || "en_US";
        s/\W.*//; # LANG=en_US.UTF-8, LANGUAGE=en_US:en
    }
    # locale, no default
}

sub _process_clause {
    my ($self, $cd, $clset_num, $clause) = @_;

    my $th = $cd->{th};
    my $tn = $cd->{type};
    my $clsets = $cd->{clsets};

    my $clset = $clsets->[$clset_num];
    local $cd->{spath}       = [@{$cd->{spath}}, $clause];
    local $cd->{clset}       = $clset;
    local $cd->{clset_num}   = $clset_num;
    local $cd->{uclset}      = $cd->{uclsets}[$clset_num];
    local $cd->{clset_dlang} = $cd->{_clset_dlangs}[$clset_num];
    #$log->tracef("Processing clause %s", $clause);

    delete $cd->{uclset}{$clause};
    delete $cd->{uclset}{"$clause.prio"};

    if ($clause ~~ $cd->{args}{skip_clause}) {
        delete $cd->{uclset}{$_}
            for grep /^\Q$clause\E(\.|\z)/, keys(%{$cd->{uclset}});
        return;
    }

    my $meth  = "clause_$clause";
    my $mmeth = "clausemeta_$clause";
    unless ($th->can($meth)) {
        for ($cd->{args}{on_unhandled_clause}) {
            next if $_ eq 'ignore';
            do { warn "Can't handle clause $clause"; next }
                if $_ eq 'warn';
            $self->_die($cd, "Can't handle clause $clause");
        }
    }

    # put information about the clause to $cd

    my $meta;
    if ($th->can($mmeth)) {
        $meta = $th->$mmeth;
    } else {
        $meta = {};
    }
    local $cd->{cl_meta} = $meta;
    $self->_die($cd, "Clause $clause doesn't allow expression")
        if $clset->{"$clause.is_expr"} && !$meta->{allow_expr};
    for my $a (keys %{ $meta->{attrs} }) {
        my $av = $meta->{attrs}{$a};
        $self->_die($cd, "Attribute $clause.$a doesn't allow ".
                        "expression")
            if $clset->{"$clause.$a.is_expr"} && !$av->{allow_expr};
    }
    local $cd->{clause} = $clause;
    my $cv = $clset->{$clause};
    my $ie = $clset->{"$clause.is_expr"};
    my $op = $clset->{"$clause.op"};
    local $cd->{cl_value}   = $cv;
    local $cd->{cl_term}    = $ie ? $self->expr($cv) : $self->literal($cv);
    local $cd->{cl_is_expr} = $ie;
    local $cd->{cl_op}      = $op;
    delete $cd->{uclset}{"$clause.is_expr"};
    delete $cd->{uclset}{"$clause.op"};

    if ($self->can("before_clause")) {
        $self->before_clause($cd);
    }
    if ($th->can("before_clause")) {
        $th->before_clause($cd);
    }
    my $tmpnam = "before_clause_$clause";
    if ($th->can($tmpnam)) {
        $th->$tmpnam($cd);
    }

    my $is_multi;
    if (defined($op) && !$ie) {
        if ($op =~ /\A(and|or|none)\z/) {
            $is_multi = 1;
        } elsif ($op eq 'not') {
            $is_multi = 0;
        } else {
            $self->_die($cd, "Invalid value for $clause.op, ".
                            "must be one of and/or/not/none");
        }
    }
    $self->_die($cd, "'$clause.op' attribute set to $op, ".
                    "but value of '$clause' clause not an array")
        if $is_multi && ref($cv) ne 'ARRAY';
    if (!$th->can($meth)) {
        # skip
    } elsif ($cd->{CLAUSE_DO_MULTI} || !$is_multi) {
        local $cd->{cl_is_multi} = 1 if $is_multi;
        $th->$meth($cd);
    } else {
        my $i = 0;
        for my $cv2 (@$cv) {
            local $cd->{spath} = [@{ $cd->{spath} }, $i];
            local $cd->{cl_value} = $cv2;
            local $cd->{cl_term}  = $self->literal($cv2);
            local $cd->{_debug_ccl_note} = "" if $i;
            $i++;
            $th->$meth($cd);
        }
    }

    $tmpnam = "after_clause_$clause";
    if ($th->can($tmpnam)) {
        $th->$tmpnam($cd);
    }
    if ($th->can("after_clause")) {
        $th->after_clause($cd);
    }
    if ($self->can("after_clause")) {
        $self->after_clause($cd);
    }

    delete $cd->{uclset}{"$clause.err_msg"};
    delete $cd->{uclset}{"$clause.err_level"};
    delete $cd->{uclset}{$_} for
        grep /\A\Q$clause\E\.human(\..+)?\z/, keys(%{$cd->{uclset}});
}

sub _process_clsets {
    my ($self, $cd, $which) = @_;

    # $which can be left undef/false if called from compile(), or set to 'from
    # clause_clset' if called from within clause_clset(), in which case
    # before_handle_type, handle_type, before_all_clauses, and after_all_clauses
    # won't be called.

    my $th = $cd->{th};
    my $tn = $cd->{type};
    my $clsets = $cd->{clsets};

    my $cname = $self->name;
    local $cd->{uclsets} = [];
    $cd->{_clset_dlangs} = []; # default lang for each clset
    for my $clset (@$clsets) {
        for (keys %$clset) {
            if (!$cd->{args}{allow_expr} && /\.is_expr\z/ && $clset->{$_}) {
                $self->_die($cd, "Expression not allowed: $_");
            }
        }
        push @{ $cd->{uclsets} }, {
            map {$_=>$clset->{$_}}
                grep {
                    !/\A_|\._/ && (!/\Ac\./ || /\Ac\.\Q$cname\E\./)
                } keys %$clset
        };
        my $dl = $clset->{default_lang} // $cd->{outer_cd}{clset_dlang} //
            "en_US";
        push @{ $cd->{_clset_dlangs} }, $dl;
    }

    my $clauses = $self->_get_clauses_from_clsets($cd, $clsets);

    if ($which) {
        # {before,after}_clause_sets is currently internal/undocumented, created
        # only for clause_clset
        if ($self->can("before_clause_sets")) {
            $self->before_clause_sets($cd);
        }
        if ($th->can("before_clause_sets")) {
            $th->before_clause_sets($cd);
        }
    } else {
        if ($self->can("before_handle_type")) {
            $self->before_handle_type($cd);
        }

        $th->handle_type($cd);

        if ($self->can("before_all_clauses")) {
            $self->before_all_clauses($cd);
        }
        if ($th->can("before_all_clauses")) {
            $th->before_all_clauses($cd);
        }
    }

    for my $clause0 (@$clauses) {
        my ($clset_num, $clause) = @$clause0;
        $self->_process_clause($cd, $clset_num, $clause);
    } # for clause

    for my $uclset (@{ $cd->{uclsets} }) {
        if (keys %$uclset) {
            for ($cd->{args}{on_unhandled_attr}) {
                my $msg = "Unhandled attribute(s) for type $tn: ".
                    join(", ", keys %$uclset);
                next if $_ eq 'ignore';
                do { warn $msg; next } if $_ eq 'warn';
                $self->_die($cd, $msg);
            }
        }
    }

    if ($which) {
        # {before,after}_clause_sets is currently internal/undocumented, created
        # only for clause_clset
        if ($th->can("after_clause_sets")) {
            $th->after_clause_sets($cd);
        }
        if ($self->can("after_clause_sets")) {
            $self->after_clause_sets($cd);
        }
    } else {
        if ($th->can("after_all_clauses")) {
            $th->after_all_clauses($cd);
        }
        if ($self->can("after_all_clauses")) {
            $self->after_all_clauses($cd);
        }
    }
}

sub compile {
    my ($self, %args) = @_;

    # XXX schema
    $self->check_compile_args(\%args);

    my $main   = $self->main;
    my $cd     = $self->init_cd(%args);

    if ($self->can("before_compile")) {
        $self->before_compile($cd);
    }

    # normalize schema
    my $schema0 = $args{schema} or $self->_die($cd, "No schema");
    my $nschema;
    if ($args{schema_is_normalized}) {
        $nschema = $schema0;
        #$log->tracef("schema already normalized, skipped normalization");
    } else {
        $nschema = $main->normalize_schema($schema0);
        $log->tracef("normalized schema=%s", $nschema);
    }
    $cd->{nschema} = $nschema;
    local $cd->{schema} = $nschema;

    {
        my $defs = $nschema->[2]{def};
        if ($defs) {
            for my $name (sort keys %$defs) {
                my $def = $defs->{$name};
                my $opt = $name =~ s/[?]\z//;
                local $cd->{def_optional} = $opt;
                local $cd->{def_name}     = $name;
                $self->_die($cd, "Invalid name syntax in def: '$name'")
                    unless $name =~ $Data::Sah::type_re;
                local $cd->{def_def}      = $def;
                $self->def($cd);
                $log->tracef("=> def() name=%s, def=>%s, optional=%s)",
                             $name, $def, $opt);
            }
        }
    }

    my $res       = $self->_resolve_base_type(schema=>$nschema, cd=>$cd);
    my $tn        = $res->[0];
    my $th        = $self->get_th(name=>$tn, cd=>$cd);
    my $clsets    = $res->[1];
    $cd->{th}     = $th;
    $cd->{type}   = $tn;
    $cd->{clsets} = $clsets;

    $self->_process_clsets($cd);

    if ($self->can("after_compile")) {
        $self->after_compile($cd);
    }

    if ($args{log_result} && $log->is_trace) {
        require String::LineNumber;
        $log->tracef(
            "Schema compilation result:\n%s",
            !ref($cd->{result}) && ($ENV{LINENUM} // 1) ?
                String::LineNumber::linenum($cd->{result}) :
                      $cd->{result}
                  );
    }
    return $cd;
}

sub def {
    my ($self, $cd) = @_;
    my $name = $cd->{def_name};
    my $def  = $cd->{def_def};
    my $opt  = $cd->{def_optional};

    my $th = $self->get_th(cd=>$cd, name=>$name, load=>0);
    if ($th) {
        if ($opt) {
            $log->tracef("Not redefining already-defined schema/type '$name'");
            return;
        }
        $self->_die($cd, "Redefining existing type ($name) not allowed");
    }

    my $nschema = $self->main->normalize_schema($def);
    $cd->{th_map}{$name} = $nschema;
}

sub _ignore_clause {
    my ($self, $cd) = @_;
    my $cl = $cd->{clause};
    delete $cd->{uclset}{$cl};
}

sub _ignore_clause_and_attrs {
    my ($self, $cd) = @_;
    my $cl = $cd->{clause};
    delete $cd->{uclset}{$cl};
    delete $cd->{uclset}{$_} for grep /\A\Q$cl\E\./, keys %{$cd->{uclset}};
}

sub _die_unimplemented_clause {
    my ($self, $cd, $note) = @_;

    $self->_die($cd, "Clause '$cd->{clause}' for type '$cd->{type}' ".
                    ($note ? "($note) " : "") .
                        "is currently unimplemented");
}

1;
# ABSTRACT: Base class for Sah compilers (Data::Sah::Compiler::*)

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler - Base class for Sah compilers (Data::Sah::Compiler::*)

=head1 VERSION

This document describes version 0.41 of Data::Sah::Compiler (from Perl distribution Data-Sah), released on 2015-01-06.

=for Pod::Coverage ^(check_compile_args|def|expr|init_cd|literal|name)$

=head1 ATTRIBUTES

=head2 main => OBJ

Reference to the main Data::Sah object.

=head2 expr_compiler => OBJ

Reference to expression compiler object. In the perl compiler, for example, this
will be an instance of L<Language::Expr::Compiler::Perl> object.

=head1 METHODS

=head2 new() => OBJ

=head2 $c->compile(%args) => HASH

Compile schema into target language.

Arguments (C<*> denotes required arguments, subclass may introduce others):

=over 4

=item * data_name => STR (default: 'data')

A unique name. Will be used as default for variable names, etc. Should only be
comprised of letters/numbers/underscores.

=item * schema* => STR|ARRAY

The schema to use. Will be normalized by compiler, unless
C<schema_is_normalized> is set to true.

=item * lang => STR (default: from LANG/LANGUAGE or C<en_US>)

Desired output human language. Defaults (and falls back to) C<en_US>.

=item * mark_missing_translation => BOOL (default: 1)

If a piece of text is not found in desired human language, C<en_US> version of
the text will be used but using this format:

 (en_US:the text to be translated)

If you do not want this marker, set the C<mark_missing_translation> option to 0.

=item * locale => STR

Locale name, to be set during generating human text description. This sometimes
needs to be if setlocale() fails to set locale using only C<lang>.

=item * schema_is_normalized => BOOL (default: 0)

If set to true, instruct the compiler not to normalize the input schema and
assume it is already normalized.

=item * allow_expr => BOOL (default: 1)

Whether to allow expressions. If false, will die when encountering expression
during compilation. Usually set to false for security reason, to disallow
complex expressions when schemas come from untrusted sources.

=item * on_unhandled_attr => STR (default: 'die')

What to do when an attribute can't be handled by compiler (either it is an
invalid attribute, or the compiler has not implemented it yet). Valid values
include: C<die>, C<warn>, C<ignore>.

=item * on_unhandled_clause => STR (default: 'die')

What to do when a clause can't be handled by compiler (either it is an invalid
clause, or the compiler has not implemented it yet). Valid values include:
C<die>, C<warn>, C<ignore>.

=item * indent_level => INT (default: 0)

Start at a specified indent level. Useful when generated code will be inserted
into another code (e.g. inside C<sub {}> where it is nice to be able to indent
the inside code).

=item * skip_clause => ARRAY (default: [])

List of clauses to skip (to assume as if it did not exist). Example when
compiling with the human compiler:

 # schema
 [int => {default=>1, between=>[1, 10]}]

 # generated human description in English
 integer, between 1 and 10, default 1

 # generated human description, with skip_clause => ['default']
 integer, between 1 and 10

=back

=head3 Compilation data

During compilation, compile() will call various hooks (listed below). The hooks
will be passed compilation data (C<$cd>) which is a hashref containing various
compilation state and result. Compilation data is written to this hashref
instead of on the object's attributes to make it easy to do recursive
compilation (compilation of subschemas).

Subclasses may add more data (see their documentation).

Keys which contain input data, compilation state, and others (many of these keys
might exist only temporarily during certain phases of compilation and will no
longer exist at the end of compilation, for example C<clause> will only exist
during processing of a clause and will be seen by hooks like C<before_clause>
and C<after_clause>, it will not be seen by C<before_all_clauses> or
C<after_compile>):

=over 4

=item * B<args> => HASH

Arguments given to C<compile()>.

=item * B<compiler> => OBJ

The compiler object.

=item * B<outer_cd> => HASH

If compilation is called from within another C<compile()>, this will be set to
the outer compilation's C<$cd>. The inner compilation will inherit some values
from the outer, like list of types (C<th_map>) and function sets (C<fsh_map>).

=item * B<th_map> => HASH

Mapping of fully-qualified type names like C<int> and its
C<Data::Sah::Compiler::*::TH::*> type handler object (or array, a normalized
schema).

=item * B<fsh_map> => HASH

Mapping of function set name like C<core> and its
C<Data::Sah::Compiler::*::FSH::*> handler object.

=item * B<schema> => ARRAY

The current schema (normalized) being processed. Since schema can contain other
schemas, there will be subcompilation and this value will not necessarily equal
to C<< $cd->{args}{schema} >>.

=item * B<spath> = ARRAY

An array of strings, with empty array (C<[]>) as the root. Point to current
location in schema during compilation. Inner compilation will continue/append
the path.

Example:

 # spath, with pointer to location in the schema

 spath: ["elems"] ----
                      \
 schema: ["array", {elems => ["float", [int => {min=>3}], [int => "div_by&" => [2, 3]]]}

 spath: ["elems", 0] ------------
                                 \
 schema: ["array", {elems => ["float", [int => {min=>3}], [int => "div_by&" => [2, 3]]]}

 spath: ["elems", 1, "min"] ---------------------
                                                 \
 schema: ["array", {elems => ["float", [int => {min=>3}], [int => "div_by&" => [2, 3]]]}

 spath: ["elems", 2, "div_by", 1] -------------------------------------------------
                                                                                   \
 schema: ["array", {elems => ["float", [int => {min=>3}], [int => "div_by&" => [2, 3]]]}

Note: aside from C<spath>, there is also the analogous C<dpath> which points to
the location of I<data> (e.g. array element, hash key). But this is declared and
maintained by the generated code, not by the compiler.

=item * B<th> => OBJ

Current type handler.

=item * B<type> => STR

Current type name.

=item * B<clsets> => ARRAY

All the clause sets. Each schema might have more than one clause set, due to
processing base type's clause set.

=item * B<clset> => HASH

Current clause set being processed. Note that clauses are evaluated not strictly
in clset order, but instead based on expression dependencies and priority.

=item * B<clset_dlang> => HASH

Default language of the current clause set. This value is taken from C<<
$cd->{clset}{default_lang} >> or C<< $cd->{outer_cd}{default_lang} >> or the
default C<en_US>.

=item * B<clset_num> => INT

Set to 0 for the first clause set, 1 for the second, and so on. Due to merging,
we might process more than one clause set during compilation.

=item * B<uclset> => HASH

Short for "unprocessed clause set", a shallow copy of C<clset>, keys will be
removed from here as they are processed by clause handlers, remaining keys after
processing the clause set means they are not recognized by hooks and thus
constitutes an error.

=item * B<uclsets> => ARRAY

All the C<uclset> for each clause set.

=item * B<clause> => STR

Current clause name.

=item * B<cl_meta> => HASH

Metadata information about the clause, from the clause definition. This include
C<prio> (priority), C<attrs> (list of attributes specific for this clause),
C<allow_expr> (whether clause allows expression in its value), etc. See
C<Data::Sah::Type::$TYPENAME> for more information.

=item * B<cl_value> => ANY

Clause value. Note: for putting in generated code, use C<cl_term>.

=item * B<cl_term> => STR

Clause value term. If clause value is a literal (C<.is_expr> is false) then it
is produced by passing clause value to C<literal()>. Otherwise, it is produced
by passing clause value to C<expr()>.

=item * B<cl_is_expr> => BOOL

A copy of C<< $cd->{clset}{"${clause}.is_expr"} >>, for convenience.

=item * B<cl_op> => STR

A copy of C<< $cd->{clset}{"${clause}.op"} >>, for convenience.

=item * B<cl_is_multi> => BOOL

Set to true if cl_value contains multiple clause values. This will happen if
C<.op> is either C<and>, C<or>, or C<none> and C<< $cd->{CLAUSE_DO_MULTI} >> is
set to true.

=item * B<indent_level> => INT

Current level of indent when printing result using C<< $c->line() >>. 0 means
unindented.

=item * B<all_expr_vars> => ARRAY

All variables in all expressions in the current schema (and all of its
subschemas). Used internally by compiler. For example (XXX syntax not not
finalized):

 # schema
 [array => {of=>'str1', min_len=>1, 'max_len=' => '$min_len*3'},
  {def => {
      str1 => [str => {min_len=>6, 'max_len=' => '$min_len*2',
                       check=>'substr($_,0,1) eq "a"'}],
  }}]

 all_expr_vars => ['schema:///clsets/0/min_len', # or perhaps .../min_len/value
                   'schema://str1/clsets/0/min_len']

This data can be used to order the compilation of clauses based on dependencies.
In the above example, C<min_len> needs to be evaluated before C<max_len>
(especially if C<min_len> is an expression).

=back

Keys which contain compilation result:

=over 4

=item * B<ccls> => [HASH, ...]

Compiled clauses, collected during processing of schema's clauses. Each element
will contain the compiled code in the target language, error message, and other
information. At the end of processing, these will be joined together.

=item * B<result>

The final result. For most compilers, it will be string/text.

=back

=head3 Return value

The compilation data will be returned as return value. Main result will be in
the C<result> key. There is also C<ccls>, and subclasses may put additional
results in other keys. Final usable result might need to be pieced together from
these results, depending on your needs.

=head3 Hooks

By default this base compiler does not define any hooks; subclasses can define
hooks to implement their compilation process. Each hook will be passed
compilation data, and should modify or set the compilation data as needed. The
hooks that compile() will call at various points, in calling order, are:

=over 4

=item * $c->before_compile($cd)

Called once at the beginning of compilation.

=item * $c->before_handle_type($cd)

=item * $th->handle_type($cd)

=item * $c->before_all_clauses($cd)

Called before calling handler for any clauses.

=item * $th->before_all_clauses($cd)

Called before calling handler for any clauses, after compiler's
before_all_clauses().

=item * $c->before_clause($cd)

Called for each clause, before calling the actual clause handler
($th->clause_NAME() or $th->clause).

=item * $th->before_clause($cd)

After compiler's before_clause() is called, I<type handler>'s before_clause()
will also be called if available.

Input and output interpretation is the same as compiler's before_clause().

=item * $th->before_clause_NAME($cd)

Can be used to customize clause.

Introduced in v0.10.

=item * $th->clause_NAME($cd)

Clause handler. Will be called only once (if C<$cd->{CLAUSE_DO_MULTI}> is set to
by other hooks before this) or once for each value in a multi-value clause (e.g.
when C<.op> attribute is set to C<and> or C<or>). For example, in this schema:

 [int => {"div_by&" => [2, 3, 5]}]

C<clause_div_by()> can be called only once with C<< $cd->{cl_value} >> set to
[2, 3, 5] or three times, each with C<< $cd->{value} >> set to 2, 3, and 5
respectively.

=item * $th->after_clause_NAME($cd)

Can be used to customize clause.

Introduced in v0.10.

=item * $th->after_clause($cd)

Called for each clause, after calling the actual clause handler
($th->clause_NAME()).

=item * $c->after_clause($cd)

Called for each clause, after calling the actual clause handler
($th->clause_NAME()).

Output interpretation is the same as $th->after_clause().

=item * $th->after_all_clauses($cd)

Called after all clauses have been compiled, before compiler's
after_all_clauses().

=item * $c->after_all_clauses($cd)

Called after all clauses have been compiled.

=item * $c->after_compile($cd)

Called at the very end before compiling process end.

=back

=head2 $c->get_th

=head2 $c->get_fsh

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Data-Sah>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Data-Sah>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Data-Sah>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
