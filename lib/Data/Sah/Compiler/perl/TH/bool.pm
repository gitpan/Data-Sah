package Data::Sah::Compiler::perl::TH::bool;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::perl::TH';
with 'Data::Sah::Type::bool';

our $VERSION = '0.07'; # VERSION

sub handle_type_check {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = "!ref($dt)";
}

sub superclause_comparable {
    my ($self, $which, $cd) = @_;
    my $c = $self->compiler;

    $c->handle_clause(
        $cd,
        on_term => sub {
            my ($self, $cd) = @_;
            my $ct = $cd->{cl_term};
            my $dt = $cd->{data_term};

            if ($which eq 'is') {
                $c->add_ccl($cd, "($dt ? 1:0) == ($ct ? 1:0)");
            } elsif ($which eq 'in') {
                $c->add_ccl($cd, "($dt ? 1:0) ~~ [map {\$_?1:0} \@{$ct}]");
            }
        },
    );
}

sub superclause_sortable {
    my ($self, $which, $cd) = @_;
    my $c = $self->compiler;

    $c->handle_clause(
        $cd,
        on_term => sub {
            my ($self, $cd) = @_;
            my $cv = $cd->{cl_value};
            my $ct = $cd->{cl_term};
            my $dt = $cd->{data_term};

            if ($which eq 'min') {
                $c->add_ccl($cd, "($dt ? 1:0) >= ($ct ? 1:0)");
            } elsif ($which eq 'xmin') {
                $c->add_ccl($cd, "($dt ? 1:0) > ($ct ? 1:0)");
            } elsif ($which eq 'max') {
                $c->add_ccl($cd, "($dt ? 1:0) <= ($ct ? 1:0)");
            } elsif ($which eq 'xmax') {
                $c->add_ccl($cd, "($dt ? 1:0) < ($ct ? 1:0)");
            } elsif ($which eq 'between') {
                if ($cd->{cl_is_expr}) {
                    $c->add_ccl($cd, "($dt ? 1:0) >= ($ct\->[0] ? 1:0) && ".
                                    "($dt ? 1:0) <= ($ct\->[1] ? 1:0)");
                } else {
                    # simplify code
                    $c->add_ccl($cd, "($dt ? 1:0) >= ($cv->[0] ? 1:0) && ".
                                    "($dt ? 1:0) <= ($cv->[1] ? 1:0)");
                }
            } elsif ($which eq 'xbetween') {
                if ($cd->{cl_is_expr}) {
                    $c->add_ccl($cd, "($dt ? 1:0) > ($ct\->[0] ? 1:0) && ".
                                    "($dt ? 1:0) < ($ct\->[1] ? 1:0)");
                } else {
                    # simplify code
                    $c->add_ccl($cd, "($dt ? 1:0) > ($cv->[0] ? 1:0) && ".
                                    "($dt ? 1:0) < ($cv->[1] ? 1:0)");
                }
            }
        },
    );
}

sub clause_is_true {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->handle_clause(
        $cd,
        on_term => sub {
            my ($self, $cd) = @_;
            my $ct = $cd->{cl_term};
            my $dt = $cd->{data_term};

            $c->add_ccl($cd, "($ct) ? $dt : !defined($ct) ? 1 : !$dt");
        },
    );
}

1;
# ABSTRACT: perl's type handler for type "bool"

__END__
=pod

=head1 NAME

Data::Sah::Compiler::perl::TH::bool - perl's type handler for type "bool"

=head1 VERSION

version 0.07

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
