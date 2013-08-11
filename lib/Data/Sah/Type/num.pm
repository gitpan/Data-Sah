package Data::Sah::Type::num;

use Moo::Role;
with 'Data::Sah::Type::BaseType';
with 'Data::Sah::Type::Comparable';
with 'Data::Sah::Type::Sortable';

our $VERSION = '0.16'; # VERSION

1;
# ABSTRACT: num type

__END__

=pod

=head1 NAME

Data::Sah::Type::num - num type

=head1 VERSION

version 0.16

=for Pod::Coverage ^(clause_.+|clausemeta_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
