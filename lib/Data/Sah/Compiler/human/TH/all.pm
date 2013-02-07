package Data::Sah::Compiler::human::TH::all;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Type::all';

our $VERSION = '0.14'; # VERSION

sub handle_type {
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
        $c->_add_msg_catalog($cd, $icd->{ccls});
        $i++;
    }

    # can we say 'NOUN1 as well as NOUN2 as well as NOUN3 ...'?
    my $can = 1;
    for my $r (@result) {
        unless (@$r == 1 && $r->[0]{type} eq 'noun') {
            $can = 0;
            last;
        }
    }

    my $vals;
    if ($can) {
        my $c0  = $c->_xlt($cd, '%(modal_verb)s be %s');
        my $awa = $c->_xlt($cd, 'as well as %s');
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
            fmt   => '%(modal_verb)s be all of the following',
            items => [
                @result,
            ],
            vals  => [],
        });
    }
}

1;
# ABSTRACT: perl's type handler for type "all"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::all - perl's type handler for type "all"

=head1 VERSION

version 0.14

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

