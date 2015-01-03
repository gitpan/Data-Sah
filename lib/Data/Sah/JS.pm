package Data::Sah::JS;

use 5.010;
use strict;
use warnings;
use Log::Any qw($log);

our $VERSION = '0.39'; # VERSION

our $Log_Validator_Code = $ENV{LOG_SAH_VALIDATOR_CODE} // 0;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(gen_validator);

# check availability of the node.js executable, return the path to executable or
# undef if none is available. node.js is normally installed as 'node', except on
# debian ('nodejs').
sub get_nodejs_path {
    require File::Which;

    my $path;
    for my $name (qw/nodejs node/) {
        $path = File::Which::which($name);
        next unless $path;

        # check if it's really nodejs
        my $cmd = "$path -e 'console.log(1+1)'";
        my $out = `$cmd`;
        if ($out =~ /\A2\n?\z/) {
            return $path;
        } else {
            #say "D:Output of $cmd: $out";
        }
    }
    return undef;
}

sub gen_validator {
    require Data::Sah;

    my ($schema, $opts) = @_;

    state $jsc = Data::Sah->new->get_compiler("js");

    my %args = (schema => $schema, %{$opts // {}});
    my $opt_source = delete $args{source};

    $args{log_result} = 1 if $Log_Validator_Code;

    my $v_src = $jsc->expr_validator_sub(%args);
    return $v_src if $opt_source;

    state $nodejs_path = get_nodejs_path();
    die "Can't find node.js in PATH" unless $nodejs_path;


    sub {
        require File::Temp;
        require JSON;
        #require String::ShellQuote;

        my $data = shift;

        state $json = JSON->new->allow_nonref;

        # code to be sent to nodejs
        my $src = "var validator = $v_src;\n\n".
            "console.log(JSON.stringify(validator(".
                $json->encode($data).")))";

        my ($jsh, $jsfn) = File::Temp::tempfile();
        print $jsh $src;
        close($jsh) or die "Can't write JS code to file $jsfn: $!";

        my $cmd = "$nodejs_path $jsfn";
        my $out = `$cmd`;
        $json->decode($out);
    };
}

1;
# ABSTRACT: Some functions to use JavaScript Sah validator code from Perl

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::JS - Some functions to use JavaScript Sah validator code from Perl

=head1 VERSION

This document describes version 0.39 of Data::Sah::JS (from Perl distribution Data-Sah), released on 2015-01-03.

=head1 SYNOPSIS

 use Data::Sah::JS qw(gen_validator);

 my $v = gen_validator(["int*", min=>1, max=>10]);

 # validate your data using the generated validator
 say "valid" if $v->(5);     # valid
 say "valid" if $v->(11);    # invalid
 say "valid" if $v->(undef); # invalid
 say "valid" if $v->("x");   # invalid

 # generate validator which reports error message string, in Indonesian
 my $v = gen_validator(["int*", min=>1, max=>10],
                       {return_type=>'str', lang=>'id_ID'});
 say $v->(5);  # ''
 say $v->(12); # 'Data tidak boleh lebih besar dari 10'
               # (in English: 'Data must not be larger than 10')

=head1 DESCRIPTION

=for Pod::Coverage ^(get_nodejs_path)$

=head1 FUNCTIONS

None exported by default.

=head2 gen_validator($schema, \%opts) => CODE (or STR)

Generate validator code for C<$schema>. This is currently used for testing
purposes only, as this will first generate JavaScript validator code, then
generate a Perl coderef that will feed generated JavaScript validator code to a
JavaScript engine (currently node.js) via command-line. Not exactly efficient.

Known options (unknown options will be passed to JS schema compiler):

=over

=item * source => BOOL (default: 0)

If set to 1, return JavaScript source code string instead of Perl coderef.
Usually only needed for debugging (but see also
C<$Data::Sah::Log_Validator_Code> and C<LOG_SAH_VALIDATOR_CODE> if you want to
log validator source code).

=back

=head1 ENVIRONMENT

L<LOG_SAH_VALIDATOR_CODE>

=head1 SEE ALSO

L<Data::Sah>, L<Data::Sah::Compiler::js>.

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
