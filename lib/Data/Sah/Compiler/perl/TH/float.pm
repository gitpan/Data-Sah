package Data::Sah::Compiler::perl::TH::float;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::perl::TH::num';
with 'Data::Sah::Type::float';

our $VERSION = '0.31'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $c->add_module($cd, 'Scalar::Util::Numeric');
    # we use isnum = isint + isfloat, because isfloat(3) is false
    $cd->{_ccl_check_type} = "Scalar::Util::Numeric::isnum($dt)";
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
                "$ct ? Scalar::Util::Numeric::isnan($dt) : ",
                "defined($ct) ? !Scalar::Util::Numeric::isnan($dt) : 1",
            )
        );
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "Scalar::Util::Numeric::isnan($dt)");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "!Scalar::Util::Numeric::isnan($dt)");
        }
    }
}

sub clause_is_pos_inf {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        $c->add_ccl($cd, "$ct ? $dt == 'inf' : ".
                        "defined($ct) ? $dt != 'inf' : 1");
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "$dt == 'inf'");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "$dt != 'inf'");
        }
    }
}

sub clause_is_neg_inf {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        $c->add_ccl($cd, "$ct ? $dt == '-inf' : ".
                        "defined($ct) ? $dt != '-inf' : 1");
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "$dt == '-inf'");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "$dt != '-inf'");
        }
    }
}

sub clause_is_inf {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        $c->add_ccl($cd, "$ct ? abs($dt) == 'inf' : ".
                        "defined($ct) ? abs($dt) != 'inf' : 1");
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "abs($dt) == 'inf'");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "abs($dt) != 'inf'");
        }
    }
}

1;
# ABSTRACT: perl's type handler for type "float"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::perl::TH::float - perl's type handler for type "float"

=head1 VERSION

This document describes version 0.31 of Data::Sah::Compiler::perl::TH::float (from Perl distribution Data-Sah), released on 2014-11-07.

=for Pod::Coverage ^(compiler|clause_.+|handle_.+)$

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

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
