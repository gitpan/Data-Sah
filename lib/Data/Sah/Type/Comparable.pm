package Data::Sah::Type::Comparable;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';

our $VERSION = '0.10'; # VERSION

requires 'superclause_comparable';

has_clause 'in',
    tags       => ['constraint'],
    arg        => '(any[])*',
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_comparable('in', $cd);
    };
has_clause 'is',
    tags       => ['constraint'],
    arg        => 'any',
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_comparable('is', $cd);
    };

1;
# ABSTRACT: Comparable type role


__END__
=pod

=head1 NAME

Data::Sah::Type::Comparable - Comparable type role

=head1 VERSION

version 0.10

=head1 DESCRIPTION

Role consumer must provide method C<superclause_comparable> which will be given
normal C<%args> given to clause methods, but with extra key C<-which> (either
C<in>, C<is>).

=for Pod::Coverage ^(clause_.+|clausemeta_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

