package Data::Sah::Type::str;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::Sortable';
with 'Data::Sah::Type::HasElems';

our $VERSION = '0.37'; # VERSION

my $t_re = 'regex*|{*=>regex*}';

has_clause 'encoding',
    tags       => ['constraint'],
    arg        => 'str*',
    allow_expr => 0,
    ;
has_clause 'match',
    tags       => ['constraint'],
    arg        => $t_re,
    allow_expr => 1,
    ;
has_clause 'is_re',
    tags       => ['constraint'],
    arg        => 'bool',
    allow_expr => 1,
    ;

1;
# ABSTRACT: str type

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Type::str - str type

=head1 VERSION

This document describes version 0.37 of Data::Sah::Type::str (from Perl distribution Data-Sah), released on 2015-01-02.

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
