package Data::Sah::Type::bool;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::Sortable';

our $VERSION = '0.10'; # VERSION

has_clause 'is_true',
    tags       => ['constraint'],
    arg        => 'bool',
    allow_expr => 1,
    ;

1;
# ABSTRACT: bool type


__END__
=pod

=head1 NAME

Data::Sah::Type::bool - bool type

=head1 VERSION

version 0.10

=for Pod::Coverage ^(clause_.+|clausemeta_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

