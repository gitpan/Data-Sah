package Data::Sah::Compiler::human::TH::Sortable;

use 5.010;
use Log::Any '$log';
use Moo::Role;
with 'Data::Sah::Type::Sortable';

our $VERSION = '0.14'; # VERSION

sub before_clause_between {
    my ($self, $cd) = @_;
    $cd->{CLAUSE_DO_MULTI} = 0;
}

sub before_clause_xbetween {
    my ($self, $cd) = @_;
    $cd->{CLAUSE_DO_MULTI} = 0;
}

sub superclause_sortable {
    my ($self, $which, $cd) = @_;
    my $c = $self->compiler;
    my $cv = $cd->{cl_value};

    if ($which eq 'min') {
        $c->add_ccl($cd, {
            expr=>1,
            fmt => '%(modal_verb)s be at least %s',
        });
    } elsif ($which eq 'xmin') {
        $c->add_ccl($cd, {
            expr=>1,
            fmt => '%(modal_verb)s be larger than %s',
        });
    } elsif ($which eq 'max') {
        $c->add_ccl($cd, {
            expr=>1,
            fmt => '%(modal_verb)s be at most %s',
        });
    } elsif ($which eq 'xmax') {
        $c->add_ccl($cd, {
            expr=>1,
            fmt => '%(modal_verb)s be smaller than %s',
        });
    } elsif ($which eq 'between') {
        $c->add_ccl($cd, {
            fmt => '%(modal_verb)s be between %s and %s',
            vals => $cv,
        });
    } elsif ($which eq 'xbetween') {
        $c->add_ccl($cd, {
            fmt => '%(modal_verb)s be larger than %s and smaller than %s',
            vals => $cv,
        });
    }
}

1;
# ABSTRACT: human's type handler for role "Sortable"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::Sortable - human's type handler for role "Sortable"

=head1 VERSION

version 0.14

=for Pod::Coverage ^(name|clause_.+|superclause_.+|before_.+|after_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

