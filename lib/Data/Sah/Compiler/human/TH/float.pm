package Data::Sah::Compiler::human::TH::float;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Compiler::human::TH::Comparable';
with 'Data::Sah::Compiler::human::TH::Sortable';
with 'Data::Sah::Type::float';

our $VERSION = '0.16'; # VERSION

sub name { "decimal number" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        type=>'noun',
        fmt => ["decimal number", "decimal numbers"],
    });
}

sub clause_is_nan {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $cv = $cd->{cl_value};
    if ($cd->{cl_is_expr}) {
        $c->add_ccl($cd, {});
    } else {
        $c->add_ccl($cd, {
            fmt => $cv ?
                q[%(modal_verb)s be a NaN] :
                    q[%(modal_verb_neg)s be a NaN],
        });
    }
}

sub clause_is_inf {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $cv = $cd->{cl_value};
    if ($cd->{cl_is_expr}) {
        $c->add_ccl($cd, {});
    } else {
        $c->add_ccl($cd, {
            fmt => $cv ?
                q[%(modal_verb)s an infinity] :
                    q[%(modal_verb_neg)s an infinity],
        });
    }
}

sub clause_is_pos_inf {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $cv = $cd->{cl_value};
    if ($cd->{cl_is_expr}) {
        $c->add_ccl($cd, {});
    } else {
        $c->add_ccl($cd, {
            fmt => $cv ?
                q[%(modal_verb)s a positive infinity] :
                    q[%(modal_verb_neg)s a positive infinity],
        });
    }
}

sub clause_is_neg_inf {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $cv = $cd->{cl_value};
    if ($cd->{cl_is_expr}) {
        $c->add_ccl($cd, {});
    } else {
        $c->add_ccl($cd, {
            fmt => $cv ?
                q[%(modal_verb)s a negative infinity] :
                    q[%(modal_verb_neg)s a negative infinity],
        });
    }
}

1;
# ABSTRACT: human's type handler for type "num"

__END__

=pod

=head1 NAME

Data::Sah::Compiler::human::TH::float - human's type handler for type "num"

=head1 VERSION

version 0.16

=for Pod::Coverage ^(name|clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
