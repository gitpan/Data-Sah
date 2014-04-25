package Data::Sah::Schema::Common;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.25'; # VERSION

sub schemas {
    {

        regex => [str => {
            name      => 'regex',
            summary   => 'Regular expression string',
            isa_regex => 1,
        }],

        pos_int => [int => {
            name      => 'pos_int',
            summary   => 'Positive integer',
            min       => 0,
        }],

        neg_int => [int => {
            name      => 'neg_int',
            summary   => 'Positive integer',
            max       => 0,
        }],

        nat_num => [int => {
            name        => 'nat_num',
            summary     => 'Natural number',
            description => <<_,

Natural numbers are whole numbers starting from 1, used for counting ('there are
6 coins on the table') and ordering ('this is the 3rd largest city in the
country').

_
            min         => 1,
        }],

    };
}

1;
# ABSTRACT: Collection of common schemas

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Schema::Common - Collection of common schemas

=head1 VERSION

version 0.25

=head1 RELEASE DATE

2014-04-25

=for Pod::Coverage ^(schemas)$

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
