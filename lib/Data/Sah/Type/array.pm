package Data::Sah::Type::array;

use Moo::Role;
use Data::Sah::Util 'has_clause', 'clause_alias';
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::HasElems';

our $VERSION = '0.07'; # VERSION

#has_clause 'elems', arg => ['array*' => {of=>'schema*'}];
clause_alias each_elem => 'of';

1;
# ABSTRACT: array type

__END__
=pod

=head1 NAME

Data::Sah::Type::array - array type

=head1 VERSION

version 0.07

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
