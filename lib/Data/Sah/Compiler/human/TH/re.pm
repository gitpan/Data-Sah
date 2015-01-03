package Data::Sah::Compiler::human::TH::re;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Type::re';

our $VERSION = '0.39'; # VERSION

sub name { "regex pattern" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        fmt   => ["regex pattern", "regex patterns"],
        type  => 'noun',
    });
}

1;
# ABSTRACT: perl's type handler for type "re"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::human::TH::re - perl's type handler for type "re"

=head1 VERSION

This document describes version 0.39 of Data::Sah::Compiler::human::TH::re (from Perl distribution Data-Sah), released on 2015-01-03.

=for Pod::Coverage ^(name|clause_.+|superclause_.+|before_.+|after_.+)$

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
