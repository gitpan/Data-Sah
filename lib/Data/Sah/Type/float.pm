package Data::Sah::Type::float;

use Moo::Role;
use Data::Sah::Util 'has_clause';
with 'Data::Sah::Type::num';

our $VERSION = '0.05'; # VERSION

has_clause 'is_nan',
    tags        => ['constraint'],
    arg         => ['bool'],
    allow_expr  => 1,
    allow_multi => 0,
    ;

has_clause 'is_inf',
    tags        => ['constraint'],
    arg         => ['bool'],
    allow_expr  => 1,
    allow_multi => 1,
    ;

has_clause 'is_pos_inf',
    tags        => ['constraint'],
    arg         => ['bool'],
    allow_expr  => 1,
    allow_multi => 1,
    ;

has_clause 'is_neg_inf',
    tags        => ['constraint'],
    arg         => ['bool'],
    allow_expr  => 1,
    allow_multi => 1,
    ;

1;
# ABSTRACT: float type


__END__
=pod

=head1 NAME

Data::Sah::Type::float - float type

=head1 VERSION

version 0.05

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

