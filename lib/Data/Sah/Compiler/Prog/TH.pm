package Data::Sah::Compiler::Prog::TH;

use Moo;
extends 'Data::Sah::Compiler::TH';

our $VERSION = '0.10'; # VERSION

sub clause_name {
    my ($self, $cd) = @_;
    $self->compiler->_ignore_clause_and_attrs($cd);
}

sub clause_summary {
    my ($self, $cd) = @_;
    $self->compiler->_ignore_clause_and_attrs($cd);
}

sub clause_description {
    my ($self, $cd) = @_;
    $self->compiler->_ignore_clause_and_attrs($cd);
}

sub clause_comment {
    my ($self, $cd) = @_;
    $self->compiler->_ignore_clause($cd);
}

sub clause_tags {
    my ($self, $cd) = @_;
    $self->compiler->_ignore_clause($cd);
}

1;
# ABSTRACT: Base class for programming-language emiting compiler's type handlers


__END__
=pod

=head1 NAME

Data::Sah::Compiler::Prog::TH - Base class for programming-language emiting compiler's type handlers

=head1 VERSION

version 0.10

=for Pod::Coverage ^(compiler|clause_.+|handle_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

