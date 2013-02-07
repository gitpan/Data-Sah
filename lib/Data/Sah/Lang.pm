package Data::Sah::Lang;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.14'; # VERSION

our @ISA    = qw(Exporter);
our @EXPORT = qw(add_translations);

sub add_translations {
    my %args = @_;

    # XXX check caller package and determine language, fill translations in
    # %Data::Sah::Lang::<lang>::translations
}

1;
# ABSTRACT: Language routines


__END__
=pod

=head1 NAME

Data::Sah::Lang - Language routines

=head1 VERSION

version 0.14

=for Pod::Coverage add_translations

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

