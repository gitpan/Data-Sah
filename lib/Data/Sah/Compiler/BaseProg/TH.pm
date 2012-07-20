package Data::Sah::Compiler::BaseProg::TH;

use Moo;
extends 'Data::Sah::Compiler::BaseCompiler::TH';

our $VERSION = '0.04'; # VERSION

sub clause_name {}
sub clause_summary {}
sub clause_description {}
sub clause_comment {}
sub clause_tags {}

1;
# ABSTRACT: Base class for programming-language emiting compiler's type handlers


__END__
=pod

=head1 NAME

Data::Sah::Compiler::BaseProg::TH - Base class for programming-language emiting compiler's type handlers

=head1 VERSION

version 0.04

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

