package Data::Sah::Compiler::human::TH::str;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Compiler::human::TH::Sortable';
with 'Data::Sah::Compiler::human::TH::Comparable';
with 'Data::Sah::Compiler::human::TH::HasElems';
with 'Data::Sah::Type::str';

our $VERSION = '0.17'; # VERSION

sub name { "text" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        fmt   => ["text", "texts"],
        type  => 'noun',
    });
}

sub clause_each_index {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    my %iargs = %{$cd->{args}};
    $iargs{outer_cd}             = $cd;
    $iargs{schema}               = $cv;
    $iargs{schema_is_normalized} = 0;
    my $icd = $c->compile(%iargs);

    $c->add_ccl($cd, {
        type  => 'list',
        fmt   => 'each subscript of text %(modal_verb)s be',
        items => [
            $icd->{ccls},
        ],
        vals  => [],
    });
}

sub clause_each_elem {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    my %iargs = %{$cd->{args}};
    $iargs{outer_cd}             = $cd;
    $iargs{schema}               = $cv;
    $iargs{schema_is_normalized} = 0;
    my $icd = $c->compile(%iargs);

    $c->add_ccl($cd, {
        type  => 'list',
        fmt   => 'each character of the text %(modal_verb)s be',
        items => [
            $icd->{ccls},
        ],
        vals  => [],
    });
}

sub clause_match {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    $c->add_ccl($cd, {
        fmt   => q[%(modal_verb)s match regex pattern %s],
        #expr  => 1, # weird
    });
}

sub clause_is_re {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    $c->add_ccl($cd, {
        fmt   => q[%(modal_verb)s be a regex pattern],
    });
}

1;
# ABSTRACT: perl's type handler for type "str"

__END__

=pod

=head1 NAME

Data::Sah::Compiler::human::TH::str - perl's type handler for type "str"

=head1 VERSION

version 0.17

=for Pod::Coverage ^(name|clause_.+|superclause_.+|before_.+|after_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
