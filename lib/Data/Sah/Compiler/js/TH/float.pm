package Data::Sah::Compiler::js::TH::float;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::js::TH::num';
with 'Data::Sah::Type::float';

our $VERSION = '0.16'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;
    my $dt = $cd->{data_term};

    $cd->{_ccl_check_type} = "(typeof($dt)=='number' || parseFloat($dt)==$dt)";
}

sub clause_is_nan {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        $c->add_ccl(
            $cd,
            join(
                "",
                "$ct ? $dt == NaN : ",
                $self->expr_defined($ct), " ? $dt != NaN : true",
            )
        );
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "$dt == NaN");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "$dt != NaN");
        }
    }
}

sub clause_is_pos_inf {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        $c->add_ccl(
            $cd,
            join(
                "",
                "$ct ? $dt == Infinity : ",
                $self->expr_defined($ct), " ? $dt != Infinity : true",
            )
        );
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "$dt == Infinity");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "$dt != Infinity");
        }
    }
}

sub clause_is_neg_inf {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        $c->add_ccl(
            $cd,
            join(
                "",
                "$ct ? $dt == -Infinity : ",
                $self->expr_defined($ct), " ? $dt != -Infinity : true",
            )
        );
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "$dt == -Infinity");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "$dt != -Infinity");
        }
    }
}

sub clause_is_inf {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        $c->add_ccl(
            $cd,
            join(
                "",
                "$ct ? Math.abs($dt) == Infinity : ",
                $self->expr_defined($ct), " ? Math.abs($dt) != Infinity : true",
            )
        );
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "Math.abs($dt) == Infinity");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "Math.abs($dt) != Infinity");
        }
    }
}

1;
# ABSTRACT: js's type handler for type "float"

__END__

=pod

=head1 NAME

Data::Sah::Compiler::js::TH::float - js's type handler for type "float"

=head1 VERSION

version 0.16

=for Pod::Coverage ^(compiler|clause_.+|handle_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut