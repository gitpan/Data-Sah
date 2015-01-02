package Test::Data::Sah;

our $DATE = '2015-01-02'; # DATE
our $VERSION = '0.37'; # VERSION

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
        my $res = $v->($test->{input});
        my $name = $test->{name} //
            "data " . dump($test->{input}) . " should".
                ($test->{valid} ? " pass" : " not pass"). " schema " .
                    dump($test->{schema});
        my $testres;
        if ($test->{valid}) {
            $testres = ok($res, $name);
        } else {
            $testres = ok(!$res, $name);
        }
        next if $testres;

        # when test fails, show the validator generated code to help debugging
        my $cd = $plc->compile(schema => $test->{schema});
        diag "schema compilation result:\n----begin generated code----\n",
            explain($cd->{result}), "\n----end generated code----\n",
                "that code should return ", ($test->{valid} ? "true":"false"),
                    " when fed \$data=", dump($test->{input}),
                        " but instead returns ", dump($res);

        # also show the result for return_type=full
        my $vfull = gen_validator($test->{schema}, {return_type=>"full"});
        diag "\nvalidator result (full):\n----begin result----\n",
            explain($vfull->($test->{input})), "----end result----";
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

This document describes version 0.37 of Test::Data::Sah (from Perl distribution Data-Sah), released on 2015-01-02.

=head1 FUNCTIONS

=head2 test_sah_cases(\@tests)

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
