package Data::Sah::Util::Func;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

our $VERSION = '0.22'; # VERSION

#use Sub::Install qw(install_sub);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       add_func
               );

sub add_func {
    my ($funcset, $func, %opts) = @_;
    # not yet implemented
}

1;
# ABSTRACT: Sah utility routines for adding function

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Util::Func - Sah utility routines for adding function

=head1 VERSION

version 0.22

=head1 DESCRIPTION

This module provides some utility routines to be used by modules that add Sah
functions.

=head1 FUNCTIONS

=head2 add_func($funcset, $func, %opts)

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
