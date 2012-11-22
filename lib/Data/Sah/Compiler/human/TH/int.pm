package Data::Sah::Compiler::human::TH::int;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH::num';
with 'Data::Sah::Type::int';

our $VERSION = '0.09'; # VERSION

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
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        type => 'clause',
        fmt  => 'be divisible by %s',
    });
}

sub clause_mod {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->handle_clause(
        $cd,
        on_term => sub {
            my ($self, $cd) = @_;
            my $ct = $cd->{cl_term};
            my $dt = $cd->{data_term};

            $c->add_ccl($cd, "$dt % $ct\->[0] == $ct\->[1]");
        },
    );
}

1;
# ABSTRACT: perl's type handler for type "int"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::int - perl's type handler for type "int"

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

