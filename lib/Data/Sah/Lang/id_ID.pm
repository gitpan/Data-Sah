package Data::Sah::Lang::id_ID;

our $VERSION = '0.09'; # VERSION

our %translations;

%translations = (
    # type: BaseType

    # type: Sortable

    # type: Comparable

    # type: HasElems

    # type: num

    # type: int
    q[integer],
    q[bilangan bulat],

    q[integers],
    q[bilangan bulat],

    q[be divisible by %s],
    q[dapat dibagi %s],

    q[leave a remainder of %s when divided by %s],
    q[menyisakan %s jika dibagi %s],
);

1;
# ABSTRACT: id_ID locale


__END__
=pod

=head1 NAME

Data::Sah::Lang::id_ID - id_ID locale

=head1 VERSION

version 0.09

=for Pod::Coverage .+

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

