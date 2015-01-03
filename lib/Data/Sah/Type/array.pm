package Data::Sah::Type::array;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause', 'has_clause_alias';
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::HasElems';

our $VERSION = '0.39'; # VERSION

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

=encoding UTF-8

=head1 NAME

Data::Sah::Type::array - array type

=head1 VERSION

This document describes version 0.39 of Data::Sah::Type::array (from Perl distribution Data-Sah), released on 2015-01-03.

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

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
