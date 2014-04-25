package Data::Sah::Compiler::Prog::TH::any;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::js::TH';
with 'Data::Sah::Type::any';

our $VERSION = '0.23'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = $c->true;
}

sub clause_of {
    my ($self, $cd) = @_;
    $self->gen_any_or_all_of("any", $cd);
}

1;
# ABSTRACT: Base class for programming language compiler handler for type "any"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::Prog::TH::any - Base class for programming language compiler handler for type "any"

=head1 VERSION

version 0.23

=head1 RELEASE DATE

2014-04-25

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Data-Sah>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Data-Sah>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Data-Sah>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
