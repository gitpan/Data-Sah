package Data::Sah::Compiler::human::TH::num;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Compiler::human::TH::Comparable';
with 'Data::Sah::Compiler::human::TH::Sortable';
with 'Data::Sah::Type::num';

our $VERSION = '0.13'; # VERSION

sub name { "number" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {type=>'noun', fmt => ["number", "numbers"]});
}

1;
# ABSTRACT: human's type handler for type "num"


__END__
=pod

=head1 NAME

Data::Sah::Compiler::human::TH::num - human's type handler for type "num"

=head1 VERSION

version 0.13

=for Pod::Coverage ^(name|clause_.+|superclause_.+|before_.+|after_.+)$

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

