package Data::Sah::Compiler::Prog::TH::all;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::Prog::TH';
with 'Data::Sah::Type::all';

our $VERSION = '0.17'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = $c->true;
}

sub clause_of {
    my ($self, $cd) = @_;
    $self->gen_any_or_all_of("all", $cd);
}

1;
# ABSTRACT: Base class for programming language compiler handler for type "all"

__END__

=pod

=head1 NAME

Data::Sah::Compiler::Prog::TH::all - Base class for programming language compiler handler for type "all"

=head1 VERSION

version 0.17

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
