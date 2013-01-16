package Data::Sah::Schemas::Common;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.12'; # VERSION

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

=head1 NAME

Data::Sah::Schemas::Common - Collection of common schemas

=head1 VERSION

version 0.12

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

