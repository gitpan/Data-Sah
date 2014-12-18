package Test::Data::Sah;

our $DATE = '2014-12-19'; # DATE
our $VERSION = '0.33'; # VERSION

use 5.010;
use strict;
use warnings;

use Data::Sah qw(gen_validator);
use Data::Dump qw(dump);
use Test::More 0.98;

use Exporter qw(import);
our @EXPORT_OK = qw(test_sah_cases);

# XXX support js & human testing too
sub test_sah_cases {
    my $tests = shift;

    my $sah = Data::Sah->new;
    my $plc = $sah->get_compiler('perl');

    for my $test (@$tests) {
        my $v = gen_validator($test->{schema});
        my $name = $test->{name} //
            "data " . dump($test->{input}) . " should".
                ($test->{valid} ? " pass" : " not pass"). " schema " .
                    dump($test->{schema});
        my $res;
        if ($test->{valid}) {
            $res = ok($v->($test->{input}), $name);
        } else {
            $res = ok(!$v->($test->{input}), $name);
        }
        next if $res;

        # when test fails, show the validator generated code to help debugging
        my $cd = $plc->compile(schema => $test->{schema});
        diag "schema compilation result: ", explain($cd->{result});

        # also show the result for return_type=full
        my $vfull = gen_validator($test->{schema}, {return_type=>"full"});
        diag "validator result (full): ", explain($vfull->($test->{input}));
    }
}

1;
# ABSTRACT: Test routines for Data::Sah

__END__

=pod

=encoding UTF-8

=head1 NAME

Test::Data::Sah - Test routines for Data::Sah

=head1 VERSION

This document describes version 0.33 of Test::Data::Sah (from Perl distribution Data-Sah), released on 2014-12-19.

=head1 FUNCTIONS

=head2 test_sah_cases(\@tests)

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
