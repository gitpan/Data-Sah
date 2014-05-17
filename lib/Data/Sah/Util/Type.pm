package Data::Sah::Util::Type;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

use Scalar::Util qw(blessed looks_like_number);

our $VERSION = '0.28'; # VERSION
our $DATE = '2014-05-17'; # DATE

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       coerce_date
               );

sub coerce_date {
    my $val = shift;
    if (!defined($val)) {
        return undef;
    } elsif (blessed($val) && $val->isa('DateTime')) {
        return $val;
    } elsif (looks_like_number($val) && $val >= 10**8 && $val <= 2**31) {
        require DateTime;
        return DateTime->from_epoch(epoch => $val);
    } elsif ($val =~ /\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/) {
        require DateTime;
        my $d;
        eval { $d = DateTime->new(year=>$1, month=>$2, day=>$3) };
        return undef if $@;
        return $d;
    } else {
        return undef;
    }
}

1;
# ABSTRACT: Utility related to data types

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Util::Type - Utility related to data types

=head1 VERSION

This document describes version 0.28 of Data::Sah::Util::Type (from Perl distribution Data-Sah), released on 2014-05-17.

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 coerce_date($val) => DATETIME OBJ|undef

Coerce value to DateTime object according to perl Sah compiler (see
L<Data::Sah::Compiler::perl::TH::date>). Return undef if value is not
acceptable.

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
