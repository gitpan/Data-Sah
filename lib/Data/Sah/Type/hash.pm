package Data::Sah::Type::hash;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause', 'has_clause_alias';
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::HasElems';

our $VERSION = '0.26'; # VERSION

has_clause_alias each_elem => 'of';

has_clause "keys",
    tags       => ['constraint'],
    arg        => ['hash*' => {values => 'schema*'}],
    allow_expr => 0,
    attrs      => {
        restrict => {
            arg        => [bool => default=>1],
            allow_expr => 0, # TODO
        },
        create_default => {
            arg        => [bool => default=>1],
            allow_expr => 0, # TODO
        },
    },
    ;
has_clause "re_keys",
    prio       => 51,
    tags       => ['constraint'],
    arg        => ['hash*' => {keys => 're*', values => 'schema*'}],
    allow_expr => 0,
    attrs      => {
        restrict => {
            arg        => [bool => default=>1],
            allow_expr => 0, # TODO
        },
    },
    ;
has_clause "req_keys",
    tags       => ['constraint'],
    arg        => ['array*'],
    allow_expr => 1,
    ;
has_clause "allowed_keys",
    tags       => ['constraint'],
    arg        => ['array*'],
    allow_expr => 1,
    ;
has_clause "allowed_keys_re",
    prio       => 51,
    tags       => ['constraint'],
    arg        => 're*',
    allow_expr => 1,
    ;
has_clause "forbidden_keys",
    tags       => ['constraint'],
    arg        => ['array*'],
    allow_expr => 1,
    ;
has_clause "forbidden_keys_re",
    prio       => 51,
    tags       => ['constraint'],
    arg        => 're*',
    allow_expr => 1,
    ;
has_clause_alias each_index => 'each_key';
has_clause_alias each_elem => 'each_value';
has_clause_alias check_each_index => 'check_each_key';
has_clause_alias check_each_elem => 'check_each_value';

# prop_alias indices => 'keys'

# prop_alias elems => 'values'

1;
# ABSTRACT: hash type

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Type::hash - hash type

=head1 VERSION

This document describes version 0.26 of module Data::Sah::Type::hash (in distribution Data-Sah), released on 2014-04-28.

=for Pod::Coverage ^(clause_.+|clausemeta_.+)$

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Data-Sah>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Data-Sah>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Data-Sah>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
