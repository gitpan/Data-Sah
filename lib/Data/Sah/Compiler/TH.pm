package Data::Sah::Compiler::TH;

use Moo;

our $VERSION = '0.09'; # VERSION

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

1;
# ABSTRACT: Base class for type handlers


__END__
=pod

=head1 NAME

Data::Sah::Compiler::TH - Base class for type handlers

=head1 VERSION

version 0.09

=for Pod::Coverage ^(compiler|clause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

