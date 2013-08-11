package Data::Sah::Type::int;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';
with 'Data::Sah::Type::num';

our $VERSION = '0.16'; # VERSION

has_clause 'mod',
    tags       => ['constraint'],
    arg        => ['array*' => {elems => [['int*' => {'!is'=>0}], 'int*']}],
    allow_expr => 1,
    ;
has_clause 'div_by',
    tags       => ['constraint'],
    arg        => ['int*' => {'!is'=>0}],
    allow_expr => 1,
    ;

1;
# ABSTRACT: int type

__END__

=pod

=head1 NAME

Data::Sah::Type::int - int type

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
