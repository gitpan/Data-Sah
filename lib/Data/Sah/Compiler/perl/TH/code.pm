package Data::Sah::Compiler::perl::TH::code;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::perl::TH';
with 'Data::Sah::Type::code';

our $VERSION = '0.11'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = "ref($dt) eq 'CODE'";
}

1;
# ABSTRACT: perl's type handler for type "code"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::perl::TH::code - perl's type handler for type "code"

=head1 VERSION

version 0.11

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

