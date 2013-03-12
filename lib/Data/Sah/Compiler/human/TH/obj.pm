package Data::Sah::Compiler::human::TH::obj;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Type::obj';

our $VERSION = '0.15'; # VERSION

sub name { "object" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        fmt   => ["object", "objects"],
        type  => 'noun',
    });
}

sub clause_can {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    $c->add_ccl($cd, {
        fmt   => q[%(modal_verb)s have method(s) %s],
        #expr  => 1, # weird
    });
}

sub clause_isa {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    $c->add_ccl($cd, {
        fmt   => q[%(modal_verb)s be subclass of %s],
    });
}

1;
# ABSTRACT: perl's type handler for type "obj"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::obj - perl's type handler for type "obj"

=head1 VERSION

version 0.15

=for Pod::Coverage ^(name|clause_.+|superclause_.+|before_.+|after_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

