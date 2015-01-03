package Data::Sah::Compiler::perl::TH;

use Moo;
extends 'Data::Sah::Compiler::Prog::TH';

our $VERSION = '0.39'; # VERSION

sub gen_each {
    my ($self, $which, $cd, $indices_expr, $elems_expr) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    local $cd->{_subdata_level} = $cd->{_subdata_level} + 1;
    my $use_dpath = $cd->{args}{return_type} ne 'bool';

    $c->add_module($cd, 'List::Util');
    my %iargs = %{$cd->{args}};
    $iargs{outer_cd}             = $cd;
    $iargs{data_name}            = '_';
    $iargs{data_term}            = '$_';
    $iargs{schema}               = $cv;
    $iargs{schema_is_normalized} = 0;
    $iargs{indent_level}++;
    my $icd = $c->compile(%iargs);
    my @code = (
        "!defined(List::Util::first(sub {!(\n",
        ($c->indent_str($cd), "(\$_sahv_dpath->[-1] = defined(\$_sahv_dpath->[-1]) ? ".
             "\$_sahv_dpath->[-1]+1 : 0),\n") x !!$use_dpath,
        $icd->{result}, "\n",
        $c->indent_str($icd), ")}, ",
        $which eq 'each_index' ? $indices_expr : $elems_expr,
        "))",
    );
    $c->add_ccl($cd, join("", @code), {subdata=>1});
}

1;
# ABSTRACT: Base class for perl type handlers

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::perl::TH - Base class for perl type handlers

=head1 VERSION

This document describes version 0.39 of Data::Sah::Compiler::perl::TH (from Perl distribution Data-Sah), released on 2015-01-03.

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

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
