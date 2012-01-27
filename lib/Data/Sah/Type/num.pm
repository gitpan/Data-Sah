package Data::Sah::Type::num;
{
  $Data::Sah::Type::num::VERSION = '0.02';
}

use Moo::Role;
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::Sortable';

1;
# ABSTRACT: Specification for num types


__END__
=pod

=head1 NAME

Data::Sah::Type::num - Specification for num types

=head1 VERSION

version 0.02

=head1 CLAUSES

Unless specified otherwise, all clauses have a priority of 50 (normal).

'num' assumes the roles L<Data::Sah::Type::BaseType>,
L<Data::Sah::Type::Comparable>, and L<Data::Sah::Type::Sortable>. Consult the
documentation of those role(s) to see what clauses are available.

Currently, num does not define additional clauses.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

