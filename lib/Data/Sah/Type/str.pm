package Data::Sah::Type::str;

use Moo::Role;
use Data::Sah::Util 'has_clause';
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::Sortable';
with 'Data::Sah::Type::HasElems';

our $VERSION = '0.05'; # VERSION

my $t_re = 'regex*|{*=>regex*}';

has_clause 'match', arg => $t_re;
has_clause 'is_re', arg => 'bool';

1;
# ABSTRACT: str type


__END__
=pod

=head1 NAME

Data::Sah::Type::str - str type

=head1 VERSION

version 0.05

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

