package Data::Sah::Compiler::Prog;

use 5.010;
use Moo;
extends 'Data::Sah::Compiler';
use Log::Any qw($log);

our $VERSION = '0.07'; # VERSION

#use Digest::MD5 qw(md5_hex);

# human compiler, to produce error messages
has hc => (
    is => 'rw',
    lazy => 1,
    default => sub {
        Data::Sah::Compiler::human->new;
    },
);

# subclass should provide a default, choices: 'shell', 'c', 'ini', 'cpp'
has comment_style => (is => 'rw');

has var_sigil => (is => 'rw', default => sub {''});

sub init_cd {
    my ($self, %args) = @_;

    my $cd = $self->SUPER::init_cd(%args);
    $cd->{vars} = [];
    if (my $ocd = $cd->{outer_cd}) {
        $cd->{subs}    = $ocd->{subs};
        $cd->{modules} = $ocd->{modules};
    } else {
        $cd->{subs}    = [];
        $cd->{modules} = [];
    }

    $cd;
}

sub check_compile_args {
    my ($self, $args) = @_;

    $self->SUPER::check_compile_args($args);

    my $ct = ($args->{code_type} //= 'validator');
    if ($ct ne 'validator') {
        $self->_die({}, "code_type currently can only be 'validator'");
    }
    my $rt = ($args->{return_type} //= 'bool');
    if ($rt !~ /\A(bool|str|full)\z/) {
        $self->_die({}, "Invalid value for return_type, ".
                        "use bool|str|full");
    }
    $args->{var_prefix} //= "_sahv_";
    $args->{sub_prefix} //= "_sahs_";
    $args->{data_term}  //= $self->var_sigil . $args->{data_name};
    $args->{data_term_is_lvalue} //= 1;
    $args->{err_term}   //= $self->var_sigil . "err_$args->{data_name}";
}

sub comment {
    my ($self, $cd, @args) = @_;
    my $style = $self->comment_style;

    if ($style eq 'shell') {
        $self->line($cd, "# ", @args);
    } elsif ($style eq 'cpp') {
        $self->line($cd, "// ", @args);
    } elsif ($style eq 'c') {
        $self->line($cd, "/* ", @args, '*/');
    } elsif ($style eq 'ini') {
        $self->line($cd, "; ", @args);
    } else {
        $self->_die($cd, "BUG: Unknown comment style: $style");
    }
    $self;
}

# enclose expression with parentheses, unless it already is
sub enclose_paren {
    my ($self, $expr, $force) = @_;
    if ($expr =~ /\A(\s*)(\(.+\)\s*)\z/os) {
        return $expr if !$force;
        return "$1($2)";
    } else {
        $expr =~ /\A(\s*)(.*)/os;
        return "$1($2)";
    }
}

sub add_module {
    my ($self, $cd, $name) = @_;

    return if $name ~~ $cd->{modules};
    push @{ $cd->{modules} }, $name;
}

sub add_var {
    my ($self, $cd, $name) = @_;

    return if $name ~~ $cd->{vars};
    push @{ $cd->{vars} }, $name;
}

sub before_compile {
    my ($self, $cd) = @_;

    $cd->{ccls} = [];
    if ($cd->{args}{data_term_is_lvalue}) {
        $cd->{data_term} = $cd->{args}{data_term};
    } else {
        my $v = $cd->{args}{var_prefix} . $cd->{args}{data_name};
        push @{ $cd->{vars} }, $v; # XXX unless already there
        $cd->{data_term} = $self->var_sigil . $v;
        # XXX perl specific!
        push @{ $cd->{ccls} }, ["(local($cd->{data_term} = $cd->{args}{data_term}), 1)"];
    }
}

sub before_clause {
    my ($self, $cd) = @_;
    if ($cd->{args}{debug}) {
        state $json = do {
            require JSON;
            JSON->new->allow_nonref;
        };
        my $cset = $cd->{cset};
        my $cl   = $cd->{clause};
        my $res  = $json->encode({
            map { $_ => $cset->{$_}}
                grep {/\A\Q$cl\E(?:\.|\z)/}
                    keys %$cset });
        $res =~ s/\n+/ /g;
        # a one-line dump of the clause, suitable for putting in generated
        # code's comment
        $cd->{_debug_ccl_note} = "clause: $res";
    } else {
        $cd->{_debug_ccl_note} = "clause: $cd->{clause}";
    }
}

# a common routine to handle a regular clause (handle .is_multi, .is_expr,
# .{min,max}_{ok,nok} attributes, produce default error message)
sub handle_clause {
    my ($self, $cd, %args) = @_;

    my @caller = caller(0);
    $self->_die($cd, "BUG: on_term not supplied by ".$caller[3])
        unless $args{on_term};

    my $clause = $cd->{clause};
    my $th     = $cd->{th};

    $self->_die($cd, "Sorry, .is_multi + .is_expr not yet supported ".
                    "(found in clause $clause)")
        if $cd->{cl_is_expr} && $cd->{cl_is_multi};

    my $cval = $cd->{cset}{$clause};
    $self->_die($cd, "'$clause.is_multi' attribute set, ".
                    "but value of '$clause' clause not an array")
        if $cd->{cl_is_multi} && ref($cval) ne 'ARRAY';
    my $cvals = $cd->{cl_is_multi} ? $cval : [$cval];
    my $occls = $cd->{ccls};
    $cd->{ccls} = [];
    my $i;
    for my $v (@$cvals) {
        local $cd->{cl_value} = $v;
        local $cd->{cl_term}  = $self->literal($v);
        local $cd->{_debug_ccl_note} = "" if $i++;
        $args{on_term}->($self, $cd);
    }
    delete $cd->{ucset}{"$clause.err_msg"};
    if (@{ $cd->{ccls} }) {
        push @$occls, {
            ccl => $self->join_ccls(
                $cd,
                $cd->{ccls},
                {
                    min_ok  => $cd->{cset}{"$clause.min_ok"},
                    max_ok  => $cd->{cset}{"$clause.max_ok"},
                    min_nok => $cd->{cset}{"$clause.min_nok"},
                    max_nok => $cd->{cset}{"$clause.max_nok"},
                },
            ),
            err_level => $cd->{cset}{"$clause.err_level"} // "error",
        };
    }
    $cd->{ccls} = $occls;

    delete $cd->{ucset}{$clause};
    delete $cd->{ucset}{"$clause.err_level"};
    delete $cd->{ucset}{"$clause.min_ok"};
    delete $cd->{ucset}{"$clause.max_ok"};
    delete $cd->{ucset}{"$clause.min_nok"};
    delete $cd->{ucset}{"$clause.max_nok"};
}

sub after_clause {
    my ($self, $cd) = @_;

    if ($cd->{args}{debug}) {
        delete $cd->{_debug_ccl_note};
    }
}

sub after_all_clauses {
    my ($self, $cd) = @_;

    # simply join them together with &&

    $cd->{result} = $self->join_ccls($cd, $cd->{ccls}, {err_msg => ''});
}

1;
# ABSTRACT: Base class for programming language compilers


__END__
=pod

=head1 NAME

Data::Sah::Compiler::Prog - Base class for programming language compilers

=head1 VERSION

version 0.07

=head1 SYNOPSIS

=head1 DESCRIPTION

This class is derived from L<Data::Sah::Compiler>. It is used as base class for
compilers which compile schemas into code (usually a validator) in programming
language targets, like L<Data::Sah::Compiler::perl> and
L<Data::Sah::Compiler::js>. The generated validator code by the compiler will be
able to validate data according to the source schema, usually without requiring
Data::Sah anymore.

Aside from Perl and JavaScript, this base class is also suitable for generating
validators in other procedural languages, like PHP, Python, and Ruby. See CPAN
if compilers for those languages exist.

Compilers using this base class are usually flexible in the kind of code they
produce:

=over 4

=item * configurable validator return type

Can generate validator that returns a simple bool result, str, or full data
structure.

=item * configurable data term

For flexibility in combining the validator code with other code, e.g. in sub
wrapper (one such application is in L<Perinci::Sub::Wrapper>).

=back

Planned future features include:

=over 4

=item * generating other kinds of code (aside from validators)

Perhaps data compliance measurer, data transformer, or whatever.

=back

=head1 ATTRIBUTES

These usually need not be set/changed by users.

=head2 comment_style => STR

Specify how comments are written in the target language. Either 'cpp' (C<//
comment>), 'shell' (C<# comment>), 'c' (C</* comment */>), or 'ini' (C<;
comment>). Each programming language subclass will set this, for example, the
perl compiler sets this to 'shell' while js sets this to 'cpp'.

=head1 METHODS

=head2 new() => OBJ

=head2 $c->compile(%args) => RESULT

Aside from BaseCompiler's arguments, this class supports these arguments (suffix
C<*> denotes required argument):

=over 4

=item * data_term => STR

A variable name or an expression in the target language that contains the data,
defaults to I<var_sigil> + C<name> if not specified.

=item * data_term_is_lvalue => BOOL (default: 1)

Whether C<data_term> can be assigned to.

=item * err_term => STR

A variable name or lvalue expression to store error message(s), defaults to
I<var_sigil> + C<err_NAME> (e.g. C<$err_data> in the Perl compiler).

=item * var_prefix => STR (default: _sahv_)

Prefix for variables declared by generated code.

=item * sub_prefix => STR (default: _sahs_)

Prefix for subroutines declared by generated code.

=item * code_type => STR (default: validator)

The kind of code to generate. For now the only valid (and default) value is
'validator'. Compiler can perhaps generate other kinds of code in the future.

=item * return_type => STR (default: bool)

Specify what kind of return value the generated code should produce. Either
C<bool>, C<str>, or C<full>.

C<bool> means generated validator code should just return true/false depending
on whether validation succeeds/fails.

C<str> means validation should return an error message string (the first one
encountered) if validation fails and an empty string/undef if validation
succeeds.

C<full> means validation should return a full data structure. From this
structure you can check whether validation succeeds, retrieve all the collected
errors/warnings, etc.

=item * debug => BOOL (default: 0)

This is a general debugging option which should turn on all debugging-related
options, e.g. produce more comments in the generated code, etc. Each compiler
might have more specific debugging options.

=item * debug_log => BOOL (default: 0)

Whether to add logging to generated code.

=back

=head3 Compilation data

This subclass adds the following compilation data (C<$cd>).

Keys which contain compilation state:

=over 4

=item * B<data_term> => ARRAY

Input data term. Set to C<< $cd->{args}{data_term} >> or a temporary variable
(if C<< $cd->{args}{data_term_is_lvalue} >> is false). Hooks should use this
instead of C<< $cd->{args}{data_term} >> directly, because aside from the
aforementioned temporary variable, data term can also change, for example if
C<default.temp> or C<prefilters.temp> attribute is set, where generated code
will operate on another temporary variable to avoid modifying the original data.
Or when C<.input> attribute is set, where generated code will operate on
variable other than data.

=back

Keys which contain compilation result:

=over 4

=item * B<modules> => ARRAY

List of module names that are required by the code, e.g. C<["Scalar::Utils",
"List::Util"]>).

=item * B<subs> => ARRAY

Contains pairs of subroutine names and definition code string, e.g. C<< [
[_sahs_zero => 'sub _sahs_zero { $_[0] == 0 }'], [_sahs_nonzero => 'sub
_sah_s_nonzero { $_[0] != 0 }'] ] >>. For flexibility, you'll need to do this
bit of arranging yourself to get the final usable code you can compile in your
chosen programming language.

=item * B<vars> => ARRAY ?

=back

=head2 $c->comment($cd, @arg)

Append a comment line to C<< $cd->{result} >>. Used by compiler; users normally
do not need this. Example:

 $c->comment($cd, 'this is a comment', ', ', 'and this one too');

When C<comment_style> is C<shell> this line will be added:

 # this is a comment, and this one too

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
