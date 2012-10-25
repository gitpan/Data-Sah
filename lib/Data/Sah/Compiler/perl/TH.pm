package Data::Sah::Compiler::perl::TH;

use Moo;
extends 'Data::Sah::Compiler::BaseProg::TH';

our $VERSION = '0.05'; # VERSION

# handled in compiler's before_all_clauses()

sub clause_default {}
sub clause_ok {}
sub clause_req {}
sub clause_forbidden {}
sub clause_prefilters {}

# handled in compiler's after_all_clauses()
#sub clause_postfilters {}

1;
# ABSTRACT: Base class for perl type handlers

__END__
=pod

=head1 NAME

Data::Sah::Compiler::perl::TH - Base class for perl type handlers

=head1 VERSION

version 0.05

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

