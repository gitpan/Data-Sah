package Data::Sah::Type::Comparable;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';

our $VERSION = '0.33'; # VERSION

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

=encoding UTF-8

=head1 NAME

Data::Sah::Type::Comparable - Comparable type role

=head1 VERSION

This document describes version 0.33 of Data::Sah::Type::Comparable (from Perl distribution Data-Sah), released on 2014-12-19.

=head1 DESCRIPTION

Role consumer must provide method C<superclause_comparable> which will be given
normal C<%args> given to clause methods, but with extra key C<-which> (either
C<in>, C<is>).

=for Pod::Coverage ^(clause_.+|clausemeta_.+)$

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Data-Sah>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Data-Sah>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Data-Sah>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
