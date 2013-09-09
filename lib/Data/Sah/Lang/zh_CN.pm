package Data::Sah::Lang::zh_CN;

use 5.010;
use strict;
use warnings;
use Tie::IxHash;

our $VERSION = '0.17'; # VERSION

our %translations;
tie %translations, 'Tie::IxHash', (

    # punctuations

    q[ ], # inter-word boundary
    q[],

    q[, ],
    q[，],

    q[: ],
    q[：],

    q[. ],
    q[。],

    q[(],
    q[（],

    q[)],
    q[）],

    # modal verbs

    q[must],
    q[必须],

    q[must not],
    q[必须不],

    q[should],
    q[应],

    q[should not],
    q[应不],

    # multi

    q[%s and %s],
    q[%s和%s],

    q[%s or %s],
    q[%s或%s],

    q[one of %s],
    q[这些值%s之一],

    q[all of %s],
    q[所有这些值%s],

    q[%(modal_verb)s satisfy all of the following],
    q[%(modal_verb)s满足所有这些条件],

    q[%(modal_verb)s satisfy one of the following],
    q[%(modal_verb)s满足这些条件之一],

    q[%(modal_verb)s satisfy none of the following],
    q[%(modal_verb_neg)s满足所有这些条件],

    # type: BaseType

    # type: Sortable

    # type: Comparable

    # type: HasElems

    # type: num

    # type: int

    q[integer],
    q[整数],

    q[integers],
    q[整数],

    q[%(modal_verb)s be divisible by %s],
    q[%(modal_verb)s被%s整除],

    q[%(modal_verb)s leave a remainder of %2$s when divided by %1$s],
    q[除以%1$s时余数%(modal_verb)s为%2$s],

);

1;
# ABSTRACT: zh_CN locale

__END__

=pod

=head1 NAME

Data::Sah::Lang::zh_CN - zh_CN locale

=head1 VERSION

version 0.17

=for Pod::Coverage .+

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
