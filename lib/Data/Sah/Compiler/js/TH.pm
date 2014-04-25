package Data::Sah::Compiler::js::TH;

use Moo;
extends 'Data::Sah::Compiler::Prog::TH';

our $VERSION = '0.24'; # VERSION

sub gen_each {
    my ($self, $which, $cd, $indices_expr, $elems_expr) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    local $cd->{_subdata_level} = $cd->{_subdata_level} + 1;
    my $use_dpath = $cd->{args}{return_type} ne 'bool';

    my %iargs = %{$cd->{args}};
    $iargs{outer_cd}             = $cd;
    $iargs{data_name}            = '_sahv_x';
    $iargs{data_term}            = '_sahv_x';
    $iargs{schema}               = $cv;
    $iargs{schema_is_normalized} = 0;
    $iargs{indent_level}++;
    my $icd = $c->compile(%iargs);
    my @code = (
        "(", ($which eq 'each_index' ? $indices_expr : $elems_expr), ").every(function(_sahv_x){ return(\n",
        # if ary == [], then set ary[0] = 0, else set ary[-1] = ary[-1]+1
        ($c->indent_str($cd), "(_sahv_dpath[_sahv_dpath.length ? _sahv_dpath.length-1 : 0] = (_sahv_dpath[_sahv_dpath.length-1]===undefined || _sahv_dpath[_sahv_dpath.length-1]===null) ? 0 : _sahv_dpath[_sahv_dpath.length-1]+1),\n") x !!$use_dpath,
        $icd->{result}, "\n",
        $c->indent_str($icd), ")})",
    );
    $c->add_ccl($cd, join("", @code), {subdata=>1});
}

1;
# ABSTRACT: Base class for js type handlers

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::js::TH - Base class for js type handlers

=head1 VERSION

version 0.24

=head1 RELEASE DATE

2014-04-25

=for Pod::Coverage ^(compiler|clause_.+|gen_.+)$

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
