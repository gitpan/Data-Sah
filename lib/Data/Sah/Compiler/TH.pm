package Data::Sah::Compiler::TH;

use 5.010;
use Moo;

our $VERSION = '0.15'; # VERSION

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

=head1 NAME

Data::Sah::Compiler::TH - Base class for type handlers

=head1 VERSION

version 0.15

=for Pod::Coverage ^(compiler|clause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

