package Data::Sah::Compiler::human::TH::buf;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH::str';

our $VERSION = '0.41'; # VERSION

sub name { "buffer" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        fmt   => ["buffer", "buffers"],
        type  => 'noun',
    });
}

1;
# ABSTRACT: perl's type handler for type "buf"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::human::TH::buf - perl's type handler for type "buf"

=head1 VERSION

This document describes version 0.41 of Data::Sah::Compiler::human::TH::buf (from Perl distribution Data-Sah), released on 2015-01-06.

=for Pod::Coverage ^(name|clause_.+|superclause_.+|before_.+|after_.+)$

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

This software is copyright (c) 2015 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
