package Data::Sah::Compiler::js::TH::all;

use 5.010;
use Log::Any '$log';
use Moo;
extends
    'Data::Sah::Compiler::js::TH',
    'Data::Sah::Compiler::Prog::TH::all';

our $VERSION = '0.31'; # VERSION

1;
# ABSTRACT: js's type handler for type "all"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::js::TH::all - js's type handler for type "all"

=head1 VERSION

This document describes version 0.31 of Data::Sah::Compiler::js::TH::all (from Perl distribution Data-Sah), released on 2014-11-07.

=for Pod::Coverage ^(clause_.+|superclause_.+)$

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
