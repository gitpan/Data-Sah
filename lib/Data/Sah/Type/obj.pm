package Data::Sah::Type::obj;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';
with 'Data::Sah::Type::BaseType';

our $VERSION = '0.23'; # VERSION

has_clause 'can',
    tags       => ['constraint'],
    arg        => 'str*', # XXX perl_method_name
    allow_expr => 1,
    ;
has_clause 'isa',
    tags       => ['constraint'],
    arg        => 'str*', # XXX perl_class_name
    allow_expr => 1,
    ;

1;
# ABSTRACT: obj type

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Type::obj - obj type

=head1 VERSION

version 0.23

=head1 RELEASE DATE

2014-04-25

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
