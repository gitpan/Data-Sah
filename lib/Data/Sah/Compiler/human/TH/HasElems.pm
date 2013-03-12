package Data::Sah::Compiler::human::TH::HasElems;

use 5.010;
use Log::Any '$log';
use Moo::Role;
with 'Data::Sah::Type::HasElems';

our $VERSION = '0.15'; # VERSION

sub before_clause {
    my ($self_th, $which, $cd) = @_;
}

sub before_clause_len_between {
    my ($self, $cd) = @_;
    $cd->{CLAUSE_DO_MULTI} = 0;
}

sub superclause_has_elems {
    my ($self_th, $which, $cd) = @_;
    my $c  = $self_th->compiler;
    my $cv = $cd->{cl_value};

    if ($which eq 'len') {
        $c->add_ccl($cd, {
            expr  => 1,
            fmt   => q[length %(modal_verb)s be %s],
        });
    } elsif ($which eq 'min_len') {
        $c->add_ccl($cd, {
            expr  => 1,
            fmt   => q[length %(modal_verb)s be at least %s],
        });
    } elsif ($which eq 'max_len') {
        $c->add_ccl($cd, {
            expr  => 1,
            fmt   => q[length %(modal_verb)s be at most %s],
        });
    } elsif ($which eq 'len_between') {
        $c->add_ccl($cd, {
            fmt   => q[length %(modal_verb)s be between %s and %s],
            vals  => $cv,
        });
    } elsif ($which eq 'each_index') {
        $self_th->clause_each_index($cd);
    } elsif ($which eq 'each_elem') {
        $self_th->clause_each_elem($cd);
    #} elsif ($which eq 'check_each_index') {
    #} elsif ($which eq 'check_each_elem') {
    #} elsif ($which eq 'uniq') {
    #} elsif ($which eq 'exists') {
    }
}

1;
# ABSTRACT: human's type handler for role "HasElems"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::HasElems - human's type handler for role "HasElems"

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

