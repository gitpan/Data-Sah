package Data::Sah;
BEGIN {
  $Data::Sah::VERSION = '0.01';
}

use 5.010;
use Data::Dump::OneLine;

sub _dump {
    my $self = shift;
    return Data::Dump::OneLine::dump_one_line(@_);
}

1;

__END__
=pod

=head1 NAME

Data::Sah

=head1 VERSION

version 0.01

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

