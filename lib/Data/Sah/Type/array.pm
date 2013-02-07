package Data::Sah::Type::array;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause', 'has_clause_alias';
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::HasElems';

our $VERSION = '0.14'; # VERSION

has_clause 'elems',
    tags       => ['constraint'],
    arg        => ['array*' => {of=>'schema*'}],
    allow_expr => 0,
    attrs      => {
        create_default => {
            arg        => [bool => default=>1],
            allow_expr => 0, # TODO
        },
    },
    ;
has_clause_alias each_elem => 'of';

1;
# ABSTRACT: array type


__END__
=pod

=head1 NAME

Data::Sah::Type::array - array type

=head1 VERSION

version 0.14

=for Pod::Coverage ^(clause_.+|clausemeta_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

