package Data::Sah::Type::all;

use Moo::Role;
use Data::Sah::Util 'has_clause';
with 'Data::Sah::Type::BaseType';

our $VERSION = '0.06'; # VERSION

has_clause 'of',
    tags       => ['constraint'],
    arg        => ['array*' => {min_len=>1, each_elem => 'schema*'}],
    allow_expr => 0,
    ;

1;
# ABSTRACT: all type


__END__
=pod

=head1 NAME

Data::Sah::Type::all - all type

=head1 VERSION

version 0.06

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

