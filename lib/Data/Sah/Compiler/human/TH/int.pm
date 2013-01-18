package Data::Sah::Compiler::human::TH::int;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH::num';
with 'Data::Sah::Type::int';

our $VERSION = '0.13'; # VERSION

sub name { "integer" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        type  => 'noun',
        fmt   => ["integer", "integers"],
    });
}

sub clause_div_by {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    if (!$cd->{cl_is_multi} && !$cd->{cl_is_expr} &&
            $cv == 2) {
        $c->add_ccl($cd, {
            fmt   => q[%(modal_verb)s be even],
        });
        return;
    }

    $c->add_ccl($cd, {
        fmt   => q[%(modal_verb)s be divisible by %s],
        expr  => 1,
    });
}

sub clause_mod {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    if (!$cd->{cl_is_multi} && !$cd->{cl_is_expr}) {
        if ($cv->[0] == 2 && $cv->[1] == 0) {
            $c->add_ccl($cd, {
                fmt   => q[%(modal_verb)s be even],
            });
        } elsif ($cv->[0] == 2 && $cv->[1] == 1) {
            $c->add_ccl($cd, {
                fmt   => q[%(modal_verb)s be odd],
            });
        }
        return;
    }

    $c->add_ccl($cd, {
        type => 'clause',
        fmt  =>
            q[%(modal_verb)s leave a remainder of %2$s when divided by %1$s],
        vals => $cv,
    });
}

1;
# ABSTRACT: human's type handler for type "int"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::int - human's type handler for type "int"

=head1 VERSION

version 0.13

=for Pod::Coverage ^(name|clause_.+|superclause_.+|before_.+|after_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

