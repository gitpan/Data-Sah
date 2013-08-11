package Data::Sah::Type::obj;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';
with 'Data::Sah::Type::BaseType';

our $VERSION = '0.16'; # VERSION

has_clause 'can',
    tags       => ['constraint'],
    arg        => 'str*', # XXX perl_method_name
    allow_expr => 1,
    ;
has_clause 'isa',
    tags       => ['constraint'],
    arg        => 'str*', # XXX perl_class_name
    allow_expr => 1,
    ;

1;
# ABSTRACT: obj type

__END__

=pod

=head1 NAME

Data::Sah::Type::obj - obj type

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
