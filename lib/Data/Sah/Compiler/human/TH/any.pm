package Data::Sah::Compiler::human::TH::any;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Type::any';

our $VERSION = '0.13'; # VERSION

sub handle_type {
    # does not have a noun
}

sub clause_of {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    my @result;
    my $i = 0;
    for my $cv2 (@$cv) {
        local $cd->{spath} = [@{$cd->{spath}}, $i];
        my %iargs = %{$cd->{args}};
        $iargs{outer_cd}             = $cd;
        $iargs{schema}               = $cv2;
        $iargs{schema_is_normalized} = 0;
        my $icd = $c->compile(%iargs);
        push @result, $icd->{ccls};
        $i++;
    }

    # can we say 'either NOUN1 or NOUN2 or NOUN3 ...'?
    my $can = 1;
    for my $r (@result) {
        unless (@$r == 1 && $r->[0]{type} eq 'noun') {
            $can = 0;
            last;
        }
    }

    my $vals;
    if ($can) {
        my $c0  = $c->_xlt($cd, '%(modal_verb)s be either %s');
        my $awa = $c->_xlt($cd, 'or %s');
        my $wb  = $c->_xlt($cd, ' ');
        my $fmt;
        my $i = 0;
        for my $r (@result) {
            $fmt .= $i ? $wb . $awa : $c0;
            push @$vals, ref($r->[0]{text}) eq 'ARRAY' ?
                $r->[0]{text}[0] : $r->[0]{text};
            $i++;
        }
        $c->add_ccl($cd, {
            fmt  => $fmt,
            vals => $vals,
            xlt  => 0,
            type => 'noun',
        });
    } else {
        $c->add_ccl($cd, {
            type  => 'list',
            fmt   => '%(modal_verb)s be one of the following',
            items => [
                @result,
            ],
            vals  => [],
        });
    }
}

1;
# ABSTRACT: perl's type handler for type "any"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::any - perl's type handler for type "any"

=head1 VERSION

version 0.13

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

