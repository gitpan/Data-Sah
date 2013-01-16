package Data::Sah::Lang::fr_FR;

use 5.010;
use strict;
use warnings;
use Tie::IxHash;

our $VERSION = '0.12'; # VERSION

our %translations;
tie %translations, 'Tie::IxHash', (

    # punctuations

    q[ ], # inter-word boundary
    q[ ],

    q[, ],
    q[, ],

    q[: ],
    q[: ],

    q[. ],
    q[. ],

    q[(],
    q[(],

    q[)],
    q[)],

    # modal verbs

    q[must],
    q[doit],

    q[must not],
    q[ne doit pas],

    q[should],
    q[devrait],

    q[should not],
    q[ne devrait pas],

    # multi

    q[%s and %s],
    q[%s et %s],

    q[%s or %s],
    q[%s ou %s],

    q[one of %s],
    q[une des %s],

    q[all of %s],
    q[toutes les valeurs %s],

    q[%(modal_verb)s satisfy all of the following],
    q[%(modal_verb)s satisfaire à toutes les conditions suivantes],

    q[%(modal_verb)s satisfy one of the following],
    q[%(modal_verb)s satisfaire l'une des conditions suivantes],

    q[%(modal_verb)s satisfy none of the following],
    q[%(modal_verb)s satisfaire à aucune des conditions suivantes],

    # type: BaseType

    # type: Sortable

    # type: Comparable

    # type: HasElems

    # type: num

    # type: int

    q[integer],
    q[nombre entier],

    q[integers],
    q[nombres entiers],

    q[%(modal_verb)s be divisible by %s],
    q[%(modal_verb)s être divisible par %s],

    q[%(modal_verb)s leave a remainder of %2$s when divided by %1$s],
    q[%(modal_verb)s laisser un reste %2$s si divisé par %1$s],

);

1;
# ABSTRACT: fr_FR locale


__END__
=pod

=head1 NAME

Data::Sah::Lang::fr_FR - fr_FR locale

=head1 VERSION

version 0.12

=for Pod::Coverage .+

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
