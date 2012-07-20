package Data::Sah::Type::Comparable;

use Moo::Role;
use Data::Sah::Util 'has_clause';

our $VERSION = '0.04'; # VERSION

requires 'superclause_comparable';

has_clause 'in',
    arg     => '(any[])*',
    code    => sub {
        my ($self, $cd) = @_;
        $self->superclause_comparable('in', $cd);
    };

has_clause 'is',
    arg  => 'any',
    code => sub {
        my ($self, $cd) = @_;
        $self->superclause_comparable('is', $cd);
    };

1;
# ABSTRACT: Specification for comparable types


__END__
=pod

=head1 NAME

Data::Sah::Type::Comparable - Specification for comparable types

=head1 VERSION

version 0.04

=head1 DESCRIPTION

This is the specification for comparable types. It provides clauses like B<is>,
B<in>, etc. It is used by most types, for example 'str', all numeric types, etc.

Role consumer must provide method 'superclause_comparable' which will be given
normal %args given to clause methods, but with extra key -which (either 'in',
'not_in', 'is', 'not').

=head1 CLAUSES

=head2 in => [VALUE, ...]

Require that the data be one of the specified choices.

See also: B<match> (for type 'str'), B<has> (for 'HasElems' types)

Examples:

 [int => {in => [1, 2, 3, 4, 5, 6]}] # single dice throw value
 [str => {'!in' => ['root', 'admin', 'administrator']}] # forbidden usernames

=head2 is => VALUE

Require that the data is the same as VALUE. Will perform a numeric comparison
for numeric types, or stringwise for string types, or deep comparison for deep
structures.

Examples:

 [int => {is => 3}]
 [int => {'is&' => [1, 2, 3, 4, 5, 6]}] # effectively the same as 'in'

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

