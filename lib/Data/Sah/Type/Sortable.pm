package Data::Sah::Type::Sortable;

use Moo::Role;
use Data::Sah::Util 'has_clause';

our $VERSION = '0.04'; # VERSION

requires 'superclause_sortable';

has_clause 'min',
    arg     => 'any*',
    code    => sub {
        my ($self, $cd) = @_;
        $self->superclause_sortable('min', $cd);
    };

has_clause 'xmin',
    arg     => 'any*',
    code    => sub {
        my ($self, $cd) = @_;
        $self->superclause_sortable('xmin', $cd);
    };

has_clause 'max',
    arg     => 'any*',
    code    => sub {
        my ($self, $cd) = @_;
        $self->superclause_sortable('max', $cd);
    };

has_clause 'xmax',
    arg     => 'any*',
    code    => sub {
        my ($self, $cd) = @_;
        $self->superclause_sortable('xmax', $cd);
    };

has_clause 'between',
    arg  => '[any*, any*]*',
    code => sub {
        my ($self, $cd) = @_;
        $self->superclause_sortable('between', $cd);
    };

has_clause 'xbetween',
    arg  => '[any*, any*]*',
    code => sub {
        my ($self, $cd) = @_;
        $self->superclause_sortable('xbetween', $cd);
    };

1;
# ABSTRACT: Specification for sortable types


__END__
=pod

=head1 NAME

Data::Sah::Type::Sortable - Specification for sortable types

=head1 VERSION

version 0.04

=head1 DESCRIPTION

This is the Sortable role. It provides clauses like 'lt' ("less than"), 'gt'
("greater than"), and so on. It is used by many types, for example 'str', all
numeric types, etc.

Role consumer must provide method 'superclause_sortable' which will receive the
same %args as clause methods, but with additional key: -which (either 'min',
'max', 'xmin', 'xmax').

=head1 CLAUSES

Unless specified otherwise, all clauses have a priority of 50 (normal).

=head2 min => VALUE

Require that the value is not less than some specified minimum (equivalent in
intention to the Perl string 'ge' operator, or the numeric >= operator).

Example:

 [int => {min => 0}] # specify positive numbers

=head2 xmin => VALUE

Require that the value is not less nor equal than some specified minimum
(equivalent in intention to the Perl string 'gt' operator, or the numeric >
operator). The "x" prefix is for "exclusive".

=head2 max => VALUE

Require that the value is less or equal than some specified maximum (equivalent
in intention to the Perl string 'le' operator, or the numeric <= operator).

=head2 xmax => VALUE

Require that the value is less than some specified maximum (equivalent in
intention to the Perl string 'lt' operator, or the numeric < operator). The "x"
prefix is for "exclusive".

=head2 between => [MIN, MAX]

A convenient clause to combine B<min> and B<max>.

Example, the following schemas are equivalent:

 [float => {between => [0.0, 1.5]}]
 [float => {min => 0.0, max => 1.5}]

=head2 xbetween => [MIN, MAX]

A convenient clause to combine B<xmin> and B<xmax>.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

