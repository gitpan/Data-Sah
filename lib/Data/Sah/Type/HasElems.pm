package Data::Sah::Type::HasElems;

use Moo::Role;
use Data::Sah::Util::Role 'has_clause';

our $VERSION = '0.40'; # VERSION

requires 'superclause_has_elems';

has_clause 'max_len',
    prio       => 51,
    arg        => ['int*' => {min=>0}],
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('max_len', $cd);
    };

has_clause 'min_len',
    arg        => ['int*' => {min=>0}],
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('min_len', $cd);
    };

has_clause 'len_between',
    arg        => ['array*' => {elems => ['int*', 'int*']}],
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('len_between', $cd);
    };

has_clause 'len',
    arg        => ['int*' => {min=>0}],
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('len', $cd);
    };

has_clause 'has',
    arg        => 'any',
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('has', $cd);
    };

has_clause 'each_index',
    arg        => 'schema*',
    allow_expr => 0,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('each_index', $cd);
    };

has_clause 'each_elem',
    arg        => 'schema*',
    allow_expr => 0,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('each_elem', $cd);
    };

has_clause 'check_each_index',
    arg        => 'schema*',
    allow_expr => 0,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('check_each_index', $cd);
    };

has_clause 'check_each_elem',
    arg        => 'schema*',
    allow_expr => 0,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('check_each_elem', $cd);
    };

has_clause 'uniq',
    arg        => 'schema*',
    allow_expr => 1,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('uniq', $cd);
    };

has_clause 'exists',
    arg        => 'schema*',
    allow_expr => 0,
    code       => sub {
        my ($self, $cd) = @_;
        $self->superclause_has_elems('exists', $cd);
    };

# has_prop 'len';

# has_prop 'elems';

# has_prop 'indices';

1;
# ABSTRACT: HasElems role

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Type::HasElems - HasElems role

=head1 VERSION

This document describes version 0.40 of Data::Sah::Type::HasElems (from Perl distribution Data-Sah), released on 2015-01-04.

=for Pod::Coverage ^(clause_.+|clausemeta_.+)$

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

perlancar <perlancar@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by perlancar@cpan.org.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
