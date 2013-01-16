package Data::Sah::Compiler::human::TH::Comparable;

use 5.010;
use Log::Any '$log';
use Moo::Role;
with 'Data::Sah::Type::Comparable';

our $VERSION = '0.12'; # VERSION

sub superclause_comparable {
    my ($self, $which, $cd) = @_;
    my $c = $self->compiler;

    my $fmt;
    if ($which eq 'is') {
        $c->add_ccl($cd, {expr=>1, multi=>1,
                          fmt => '%(modal_verb)s have the value %s'});
    } elsif ($which eq 'in') {
        $c->add_ccl($cd, {expr=>1, multi=>1,
                          fmt => '%(modal_verb)s one of %s'});
    }
}
1;
# ABSTRACT: human's type handler for role "Comparable"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::Comparable - human's type handler for role "Comparable"

=head1 VERSION

version 0.12

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

