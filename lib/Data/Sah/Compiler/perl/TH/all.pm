package Data::Sah::Compiler::perl::TH::all;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::perl::TH';
with 'Data::Sah::Type::all';

our $VERSION = '0.06'; # VERSION

sub handle_type_check {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = "1";
}

sub clause_of {
    my ($self_th, $cd) = @_;
    my $c = $self_th->compiler;

    $c->handle_clause(
        $cd,
        on_term => sub {
            my ($self, $cd) = @_;
            $self_th->gen_any_or_all_of("all", $cd);
        },
    );
}

1;
# ABSTRACT: perl's type handler for type "all"

__END__
=pod

=head1 NAME

Data::Sah::Compiler::perl::TH::all - perl's type handler for type "all"

=head1 VERSION

version 0.06

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

