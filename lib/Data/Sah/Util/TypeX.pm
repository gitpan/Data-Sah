package Data::Sah::Util::TypeX;

use 5.010;
use strict;
use warnings;
use Log::Any '$log';

our $VERSION = '0.15'; # VERSION

#use Sub::Install qw(install_sub);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       add_clause
               );

sub add_clause {
    my ($type, $clause, %opts) = @_;
    # not yet implemented

    # * check duplicate

    # * call Data::Sah::Util::Role::has_clause
    # * install handlers to Data::Sah::Compiler::$Compiler::TH::$type
    # * push @{ $Data::Sah::Compiler::human::TypeX{$type} }, $clause;
}

1;
# ABSTRACT: Sah utility routines for type extensions


__END__
=pod

=head1 NAME

Data::Sah::Util::TypeX - Sah utility routines for type extensions

=head1 VERSION

version 0.15

=head1 DESCRIPTION

This module provides some utility routines to be used by type extension modules
(C<Data::Sah::TypeX::*>).

=head1 FUNCTIONS

=head2 add_clause($type, $clause, %opts)

Add a clause. Used when wanting to add a clause to an existing type.

Options:

=over 4

=item * definition => HASH

Will be passed to L<Data::Sah::Util::Role>'s C<has_clause>.

=item * handlers => HASH

A mapping of compiler name and coderefs. Coderef will be installed as
C<clause_$clause> in the C<Data::Sah::Compiler::$Compiler::TH::>.

=item * prio => $priority

Optional. Default is 50. The higher the priority, the earlier the clause will be
processed.

=item * aliases => \@aliases OR $alias

Define aliases. Optional.

=item * code => $code

Optional. Define implementation for the clause. The code will be installed as
'clause_$name'.

=back

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

