package Data::Sah::Compiler::TH;

use 5.010;
use Moo;

our $VERSION = '0.41'; # VERSION

# reference to compiler object
has compiler => (is => 'rw');

sub clause_v {
    my ($self, $cd) = @_;
    $self->compiler->_ignore_clause($cd);
}

sub clause_default_lang {
    my ($self, $cd) = @_;
    $self->compiler->_ignore_clause($cd);
}

sub clause_clause {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    my ($clause, $clv) = @$cv;
    my $meth   = "clause_$clause";
    my $mmeth  = "clausemeta_$clause";

    # provide an illusion of a clsets
    my $clsets = [{$clause => $clv}];
    local $cd->{clsets} = $clsets;

    $c->_process_clause($cd, 0, $clause);
}

# clause_clset, like clause_clause, also works by doing what compile() does.

sub clause_clset {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    # provide an illusion of a clsets
    local $cd->{clsets} = [$cv];
    $c->_process_clsets($cd, 'from clause_clset');
}

1;
# ABSTRACT: Base class for type handlers

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::TH - Base class for type handlers

=head1 VERSION

This document describes version 0.41 of Data::Sah::Compiler::TH (from Perl distribution Data-Sah), released on 2015-01-06.

=for Pod::Coverage ^(compiler|clause_.+)$

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

This software is copyright (c) 2015 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
