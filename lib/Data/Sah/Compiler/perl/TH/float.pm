package Data::Sah::Compiler::perl::TH::float;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::perl::TH::num';
with 'Data::Sah::Type::float';

our $VERSION = '0.10'; # VERSION

my $LLN = "Scalar::Util::looks_like_number";

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $c->add_module($cd, 'Scalar::Util');
    $cd->{_ccl_check_type} = "$LLN($dt) =~ " .
        '/^(?:1|2|9|10|4352|4|5|6|12|13|14|20|28|36|44|8704)$/';
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
                "$ct ? $LLN($dt) =~ /^(36|44)\$/ : ",
                "defined($ct) ? $LLN($dt) !~ /^(36|44)\$/ : 1",
            )
        );
    } else {
        if ($cd->{cl_value}) {
            $c->add_ccl($cd, "$LLN($dt) =~ /^(36|44)\$/");
        } elsif (defined $cd->{cl_value}) {
            $c->add_ccl($cd, "$LLN($dt) !~ /^(36|44)\$/");
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

=head1 NAME

Data::Sah::Compiler::perl::TH::float - perl's type handler for type "float"

=head1 VERSION

version 0.10

=for Pod::Coverage ^(compiler|clause_.+|handle_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

