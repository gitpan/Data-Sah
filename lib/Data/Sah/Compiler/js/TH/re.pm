package Data::Sah::Compiler::js::TH::re;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::js::TH';
with 'Data::Sah::Type::re';

our $VERSION = '0.18'; # VERSION

# XXX prefilter to convert string to regex object

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = "$dt instanceof RegExp";
}

1;
# ABSTRACT: js's type handler for type "re"

__END__

=pod

=head1 NAME

Data::Sah::Compiler::js::TH::re - js's type handler for type "re"

=head1 VERSION

version 0.18

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
