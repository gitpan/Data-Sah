package Data::Sah::Compiler::js::TH::hash;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::js::TH';
with 'Data::Sah::Type::hash';

our $VERSION = '0.19'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    # XXX also exclude RegExp, ...
    $cd->{_ccl_check_type} = "typeof($dt)=='object' && !($dt instanceof Array)";
}

my $STR = "JSON.stringify";

sub superclause_comparable {
    my ($self, $which, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'is') {
        $c->add_ccl($cd, "$STR($dt) == $STR($ct)");
    } elsif ($which eq 'in') {
        $c->add_ccl(
            $cd,
            "!($ct).every(function(x){return $STR(x) != $STR($dt) })");
    }
}

sub superclause_has_elems {
    my ($self_th, $which, $cd) = @_;
    my $c  = $self_th->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    # XXX need to optimize, Object.keys(h).length is not efficient

    if ($which eq 'len') {
        $c->add_ccl($cd, "Object.keys($dt).length == $ct");
    } elsif ($which eq 'min_len') {
        $c->add_ccl($cd, "Object.keys($dt).length >= $ct");
    } elsif ($which eq 'max_len') {
        $c->add_ccl($cd, "Object.keys($dt).length <= $ct");
    } elsif ($which eq 'len_between') {
        if ($cd->{cl_is_expr}) {
            $c->add_ccl(
                $cd, "Object.keys($dt).length >= $ct\->[0] && ".
                    "Object.keys($dt).length >= $ct\->[1]");
        } else {
            # simplify code
            $c->add_ccl(
                $cd, "Object.keys($dt).length >= $cv->[0] && ".
                    "Object.keys($dt).length <= $cv->[1]");
        }
    } elsif ($which eq 'has') {
        $c->add_ccl(
            $cd,
            "!Object.keys($dt).every(function(x){return $STR(($dt)[x]) != $STR($ct) })");
    } elsif ($which eq 'each_index' || $which eq 'each_elem') {
        $self_th->gen_each($which, $cd, "Object.keys($dt)",
                           "Object.keys($dt).map(function(x){ return $dt\[x] })");
    } elsif ($which eq 'check_each_index') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    } elsif ($which eq 'check_each_elem') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    } elsif ($which eq 'uniq') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    } elsif ($which eq 'exists') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    }
}

sub clause_keys {
    my ($self_th, $cd) = @_;
    my $c  = $self_th->compiler;
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    local $cd->{_subdata_level} = $cd->{_subdata_level} + 1;
    my $use_dpath = $cd->{args}{return_type} ne 'bool';

    # we handle subdata manually here, because in generated code for
    # keys.restrict, we haven't delved into the keys

    my $jccl;
    {
        local $cd->{ccls} = [];

        if ($cd->{clset}{"keys.restrict"} // 1) {
            local $cd->{_debug_ccl_note} = "keys.restrict";
            $c->add_ccl(
                $cd,
                "Object.keys($dt).every(function(x){ return ".$c->literal([keys %$cv]).".indexOf(x) > -1 })",
                {
                    err_msg => 'TMP1',
                    err_expr => join(
                        "",
                        $c->literal($c->_xlt(
                            $cd, "hash contains ".
                                "unknown field(s) (%s)")),
                        '.replace("%s", ',
                        "Object.keys($dt).filter(function(x){ ".$c->literal([keys %$cv]).".indexOf(x) == -1 }).join(', ')",
                        ')',
                    ),
                },
            );
        }
        delete $cd->{uclset}{"keys.restrict"};

        my $cdef = $cd->{clset}{"keys.create_default"} // 1;
        delete $cd->{uclset}{"keys.create_default"};

        #local $cd->{args}{return_type} = 'bool';
        my $nkeys = scalar(keys %$cv);
        my $i = 0;
        for my $k (keys %$cv) {
            local $cd->{spath} = [@{ $cd->{spath} }, $k];
            ++$i;
            my $sch = $c->main->normalize_schema($cv->{$k});
            my $kdn = $k; $kdn =~ s/\W+/_/g;
            my $kdt = "$dt\[".$c->literal($k)."]";
            my %iargs = %{$cd->{args}};
            $iargs{outer_cd}             = $cd;
            $iargs{data_name}            = $kdn;
            $iargs{data_term}            = $kdt;
            $iargs{schema}               = $sch;
            $iargs{schema_is_normalized} = 1;
            $iargs{indent_level}++;
            my $icd = $c->compile(%iargs);

            # should we set default for hash value?
            my $sdef = $cdef && defined($sch->[1]{default});

            $c->add_var($cd, '_sahv_stack', []) if $use_dpath;

            my @code = (
                ($c->indent_str($cd), "(_sahv_dpath.push(null), _sahv_stack.push(null), _sahv_stack[_sahv_stack.length-1] = \n")
                    x !!($use_dpath && $i == 1),

                $sdef ? "" : "!$dt.hasOwnProperty(".$c->literal($k).") || (",

                ($c->indent_str($cd), "(_sahv_dpath[_sahv_dpath.length-1] = ".
                     $c->literal($k)."),\n") x !!$use_dpath,
                $icd->{result}, "\n",

                $sdef ? "" : ")",

                ($c->indent_str($cd), "), _sahv_dpath.pop(), _sahv_stack.pop()\n")
                    x !!($use_dpath && $i == $nkeys),
            );
            my $ires = join("", @code);
            local $cd->{_debug_ccl_note} = "key: ".$c->literal($k);
            $c->add_ccl($cd, $ires);
        }
        $jccl = $c->join_ccls(
            $cd, $cd->{ccls}, {err_msg => ''});
    }
    $c->add_ccl($cd, $jccl, {});
}

sub clause_re_keys {
    my ($self, $cd) = @_;
    $self->compiler->_die_unimplemented_clause($cd);
}

sub clause_req_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    $c->add_ccl(
      $cd,
      "($ct).every(function(x){ return Object.keys($dt).indexOf(x) > -1 })", # XXX cache Object.keys($dt)
      {
        err_msg => 'TMP',
        err_expr => join(
            "",
            $c->literal($c->_xlt(
                $cd, "hash has missing required field(s) (%s)")),
            '.replace("%s", ',
            "Object.keys($dt).filter(function(x){ return ($ct).indexOf(x) == -1 }).join(', ')",
            ')',
        ),
      }
    );
}

sub clause_allowed_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    $c->add_ccl(
      $cd,
      "Object.keys($dt).every(function(x){ return ($ct).indexOf(x) > -1 })", # XXX cache Object.keys($ct)
      {
        err_msg => 'TMP',
        err_expr => join(
            "",
            $c->literal($c->_xlt(
                $cd, "hash contains non-allowed field(s) (%s)")),
            '.replace("%s", ',
            "Object.keys($dt).filter(function(x){ return ($ct).indexOf(x) == -1 }).join(', ')",
            ')',
        ),
      }
    );
}

sub clause_allowed_keys_re {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    #my $ct = $cd->{cl_term};
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        # i'm lazy atm and does not need expr yet
        $c->_die_unimplemented_clause($cd, "with expr");
    }

    my $re = $c->_str2reliteral($cd, $cv);
    $c->add_ccl(
      $cd,
      "Object.keys($dt).every(function(x){ return x.match(RegExp($re)) })",
      {
        err_msg => 'TMP',
        err_expr => join(
            "",
            $c->literal($c->_xlt(
                $cd, "hash contains non-allowed field(s) (%s)")),
            '.replace("%s", ',
            "Object.keys($dt).filter(function(x){ return !x.match(RegExp($re)) }).join(', ')",
            ')',
        ),
      }
    );
}

sub clause_forbidden_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    $c->add_ccl(
      $cd,
      "Object.keys($dt).every(function(x){ return ($ct).indexOf(x) == -1 })", # XXX cache Object.keys($ct)
      {
        err_msg => 'TMP',
        err_expr => join(
            "",
            $c->literal($c->_xlt(
                $cd, "hash contains forbidden field(s) (%s)")),
            '.replace("%s", ',
            "Object.keys($dt).filter(function(x){ return ($ct).indexOf(x) > -1 }).join(', ')",
            ')',
        ),
      }
    );
}

sub clause_forbidden_keys_re {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    #my $ct = $cd->{cl_term};
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        # i'm lazy atm and does not need expr yet
        $c->_die_unimplemented_clause($cd, "with expr");
    }

    my $re = $c->_str2reliteral($cd, $cv);
    $c->add_ccl(
      $cd,
      "Object.keys($dt).every(function(x){ return !x.match(RegExp($re)) })",
      {
        err_msg => 'TMP',
        err_expr => join(
            "",
            $c->literal($c->_xlt(
                $cd, "hash contains forbidden field(s) (%s)")),
            '.replace("%s", ',
            "Object.keys($dt).filter(function(x){ return x.match(RegExp($re)) }).join(', ')",
            ')',
        ),
      }
    );
}

1;
# ABSTRACT: js's type handler for type "hash"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::js::TH::hash - js's type handler for type "hash"

=head1 VERSION

version 0.19

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Data-Sah>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Data-Sah>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Data-Sah>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
