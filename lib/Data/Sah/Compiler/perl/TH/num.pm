package Data::Sah::Compiler::perl::TH::num;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::perl::TH';
with 'Data::Sah::Type::num';

our $VERSION = '0.09'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $c->add_module($cd, 'Scalar::Util');
    $cd->{_ccl_check_type} = "Scalar::Util::looks_like_number($dt)";
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
                $c->add_ccl($cd, "$dt == $ct");
            } elsif ($which eq 'in') {
                $c->add_ccl($cd, "$dt ~~ $ct");
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
                $c->add_ccl($cd, "$dt >= $ct");
            } elsif ($which eq 'xmin') {
                $c->add_ccl($cd, "$dt > $ct");
            } elsif ($which eq 'max') {
                $c->add_ccl($cd, "$dt <= $ct");
            } elsif ($which eq 'xmax') {
                $c->add_ccl($cd, "$dt < $ct");
            } elsif ($which eq 'between') {
                if ($cd->{cl_is_expr}) {
                    $c->add_ccl($cd, "$dt >= $ct\->[0] && $dt <= $ct\->[1]");
                } else {
                    # simplify code
                    $c->add_ccl($cd, "$dt >= $cv->[0] && $dt <= $cv->[1]");
                }
            } elsif ($which eq 'xbetween') {
                if ($cd->{cl_is_expr}) {
                    $c->add_ccl($cd, "$dt > $ct\->[0] && $dt < $ct\->[1]");
                } else {
                    # simplify code
                    $c->add_ccl($cd, "$dt > $cv->[0] && $dt < $cv->[1]");
                }
            }
        },
    );
}

1;
# ABSTRACT: perl's type handler for type "num"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::perl::TH::num - perl's type handler for type "num"

=head1 VERSION

version 0.09

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

