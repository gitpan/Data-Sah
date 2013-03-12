package Data::Sah::Compiler::js::TH::all;

use 5.010;
use Log::Any '$log';
use Moo;
extends
    'Data::Sah::Compiler::js::TH',
    'Data::Sah::Compiler::Prog::TH::all';

our $VERSION = '0.15'; # VERSION

1;
# ABSTRACT: js's type handler for type "all"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::js::TH::all - js's type handler for type "all"

=head1 VERSION

version 0.15

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

