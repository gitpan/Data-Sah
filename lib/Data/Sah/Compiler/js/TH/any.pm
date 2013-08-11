package Data::Sah::Compiler::js::TH::any;

use 5.010;
use Log::Any '$log';
use Moo;
extends
    'Data::Sah::Compiler::js::TH',
    'Data::Sah::Compiler::Prog::TH::any';

our $VERSION = '0.16'; # VERSION

1;
# ABSTRACT: js's type handler for type "any"

__END__

=pod

=head1 NAME

Data::Sah::Compiler::js::TH::any - js's type handler for type "any"

=head1 VERSION

version 0.16

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut