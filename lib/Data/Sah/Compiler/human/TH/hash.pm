package Data::Sah::Compiler::human::TH::hash;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::human::TH';
with 'Data::Sah::Compiler::human::TH::Comparable';
with 'Data::Sah::Compiler::human::TH::HasElems';
with 'Data::Sah::Type::hash';

our $VERSION = '0.27'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    $c->add_ccl($cd, {
        fmt   => ["hash", "hashes"],
        type  => 'noun',
    });
}

sub clause_has {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;

    $c->add_ccl($cd, {
        expr=>1, multi=>1,
        fmt => "%(modal_verb)s have %s in its field values"});
}

sub clause_each_index {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    my %iargs = %{$cd->{args}};
    $iargs{outer_cd}             = $cd;
    $iargs{schema}               = $cv;
    $iargs{schema_is_normalized} = 0;
    my $icd = $c->compile(%iargs);

    $c->add_ccl($cd, {
        type  => 'list',
        fmt   => 'field name %(modal_verb)s be',
        items => [
            $icd->{ccls},
        ],
        vals  => [],
    });
}

sub clause_each_elem {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    my %iargs = %{$cd->{args}};
    $iargs{outer_cd}             = $cd;
    $iargs{schema}               = $cv;
    $iargs{schema_is_normalized} = 0;
    my $icd = $c->compile(%iargs);

    $c->add_ccl($cd, {
        type  => 'list',
        fmt   => 'each field %(modal_verb)s be',
        items => [
            $icd->{ccls},
        ],
        vals  => [],
    });
}

sub clause_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    for my $k (sort keys %$cv) {
        local $cd->{spath} = [@{$cd->{spath}}, $k];
        my $v = $cv->{$k};
        my %iargs = %{$cd->{args}};
        $iargs{outer_cd}             = $cd;
        $iargs{schema}               = $v;
        $iargs{schema_is_normalized} = 0;
        my $icd = $c->compile(%iargs);
        $c->add_ccl($cd, {
            type  => 'list',
            fmt   => 'field %s %(modal_verb)s be',
            vals  => [$k],
            items => [ $icd->{ccls} ],
        });
    }
}

sub clause_re_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};

    for my $k (sort keys %$cv) {
        local $cd->{spath} = [@{$cd->{spath}}, $k];
        my $v = $cv->{$k};
        my %iargs = %{$cd->{args}};
        $iargs{outer_cd}             = $cd;
        $iargs{schema}               = $v;
        $iargs{schema_is_normalized} = 0;
        my $icd = $c->compile(%iargs);
        $c->add_ccl($cd, {
            type  => 'list',
            fmt   => 'fields whose names match regex pattern %s %(modal_verb)s be',
            vals  => [$k],
            items => [ $icd->{ccls} ],
        });
    }
}

sub clause_req_keys {
  my ($self, $cd) = @_;
  my $c  = $self->compiler;

  $c->add_ccl($cd, {
    fmt   => q[%(modal_verb)s have required fields %s],
    expr  => 1,
  });
}

sub clause_allowed_keys {
  my ($self, $cd) = @_;
  my $c  = $self->compiler;

  $c->add_ccl($cd, {
    fmt   => q[%(modal_verb)s only have these allowed fields %s],
    expr  => 1,
  });
}

sub clause_allowed_keys_re {
  my ($self, $cd) = @_;
  my $c  = $self->compiler;

  $c->add_ccl($cd, {
    fmt   => q[%(modal_verb)s only have fields matching regex pattern %s],
    expr  => 1,
  });
}

sub clause_forbidden_keys {
  my ($self, $cd) = @_;
  my $c  = $self->compiler;

  $c->add_ccl($cd, {
    fmt   => q[%(modal_verb_neg)s have these forbidden fields %s],
    expr  => 1,
  });
}

sub clause_forbidden_keys_re {
  my ($self, $cd) = @_;
  my $c  = $self->compiler;

  $c->add_ccl($cd, {
    fmt   => q[%(modal_verb_neg)s have fields matching regex pattern %s],
    expr  => 1,
  });
}

1;
# ABSTRACT: human's type handler for type "hash"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::human::TH::hash - human's type handler for type "hash"

=head1 VERSION

This document describes version 0.27 of Data::Sah::Compiler::human::TH::hash (from Perl distribution Data-Sah), released on 2014-05-04.

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
