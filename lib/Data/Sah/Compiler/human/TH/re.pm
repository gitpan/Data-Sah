package Data::Sah::Compiler::human::TH::re;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Type::re';

our $VERSION = '0.17'; # VERSION

sub name { "regex pattern" }

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        fmt   => ["regex pattern", "regex patterns"],
        type  => 'noun',
    });
}

1;
# ABSTRACT: perl's type handler for type "re"

__END__

=pod

=head1 NAME

Data::Sah::Compiler::human::TH::re - perl's type handler for type "re"

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
