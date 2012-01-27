package Data::Sah::Type::buf;
{
  $Data::Sah::Type::buf::VERSION = '0.02';
}

use Moo::Role;
with 'Data::Sah::Type::str';

1;
# Specification for type 'buf'


__END__
=pod

=head1 NAME

Data::Sah::Type::buf

=head1 VERSION

version 0.02

=head1 DESCRIPTION

'buf' stores binary data. Elements of buf data are bytes.

=head1 CLAUSES

buf derives from L<Data::Sah::Type::str>. Consult the documentation of those
role(s) to see what clauses are available.

Currently buf does not define additional clauses.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

