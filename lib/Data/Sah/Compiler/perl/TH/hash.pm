package Data::Sah::Compiler::perl::TH::hash;

use 5.010;
use Log::Any '$log';
use Moo;
use experimental 'smartmatch';
extends 'Data::Sah::Compiler::perl::TH';
with 'Data::Sah::Type::hash';

our $VERSION = '0.41'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = "ref($dt) eq 'HASH'";
}

my $FRZ = "Storable::freeze";

sub superclause_comparable {
    my ($self, $which, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    # Storable is chosen because it's core and fast. ~~ is not very
    # specific.
    $c->add_module($cd, 'Storable');

    if ($which eq 'is') {
        $c->add_ccl($cd, "$FRZ($dt) eq $FRZ($ct)");
    } elsif ($which eq 'in') {
        $c->add_smartmatch_pragma($cd);
        $c->add_ccl($cd, "$FRZ($dt) ~~ [map {$FRZ(\$_)} \@{ $ct }]");
    }
}

sub superclause_has_elems {
    my ($self_th, $which, $cd) = @_;
    my $c  = $self_th->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'len') {
        $c->add_ccl($cd, "keys(\%{$dt}) == $ct");
    } elsif ($which eq 'min_len') {
        $c->add_ccl($cd, "keys(\%{$dt}) >= $ct");
    } elsif ($which eq 'max_len') {
        $c->add_ccl($cd, "keys(\%{$dt}) <= $ct");
    } elsif ($which eq 'len_between') {
        if ($cd->{cl_is_expr}) {
            $c->add_ccl(
                $cd, "keys(\%{$dt}) >= $ct\->[0] && ".
                    "keys(\%{$dt}) >= $ct\->[1]");
        } else {
            # simplify code
            $c->add_ccl(
                $cd, "keys(\%{$dt}) >= $cv->[0] && ".
                    "keys(\%{$dt}) <= $cv->[1]");
        }
    } elsif ($which eq 'has') {
        $c->add_smartmatch_pragma($cd);
        #$c->add_ccl($cd, "$FRZ($ct) ~~ [map {$FRZ(\$_)} values \%{ $dt }]");

        # XXX currently we choose below for speed, but only works for hash of
        # scalars. stringifying is required because smartmatch will switch to
        # numeric if we feed something like {a=>1}
        $c->add_ccl($cd, "$ct ~~ [values \%{ $dt }]");
    } elsif ($which eq 'each_index' || $which eq 'each_elem') {
        $self_th->gen_each($which, $cd, "sort keys(\%{$dt})",
                           "sort values(\%{$dt})");
    } elsif ($which eq 'check_each_index') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    } elsif ($which eq 'check_each_elem') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    } elsif ($which eq 'uniq') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    } elsif ($which eq 'exists') {
        $self_th->compiler->_die_unimplemented_clause($cd);
    }
}

sub _clause_keys_or_re_keys {
    my ($self_th, $which, $cd) = @_;
    my $c  = $self_th->compiler;
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    local $cd->{_subdata_level} = $cd->{_subdata_level} + 1;
    my $use_dpath = $cd->{args}{return_type} ne 'bool';

    # we handle subdata manually here, because in generated code for
    # {keys,re_keys}.restrict, we haven't delved into the keys

    my $jccl;
    {
        local $cd->{ccls} = [];

        my $lit_valid_keys;
        if ($which eq 'keys') {
            $lit_valid_keys = $c->literal([sort keys %$cv]);
        } else {
            $lit_valid_keys = "[".
                join(",", map { "qr/".$c->_str2reliteral($cd, $_)."/" }
                         sort keys %$cv)."]";
        }

        if ($cd->{clset}{"$which.restrict"} // 1) {
            local $cd->{_debug_ccl_note} = "$which.restrict";
            $c->add_module($cd, "List::Util");
            $c->add_smartmatch_pragma($cd);
            $c->add_ccl(
                $cd,
                # here we need ~~ because it can match against strs or regexes
                "!defined(List::Util::first(sub {!(\$_ ~~ $lit_valid_keys)}, ".
                    "keys %{$dt}))",
                {
                    err_msg => 'TMP1',
                    err_expr => join(
                        "",
                        'sprintf(',
                        $c->literal($c->_xlt(
                            $cd, "hash contains ".
                                "unknown field(s) (%s)")),
                        ',',
                        "join(', ', sort grep {!(\$_ ~~ $lit_valid_keys)} ",
                        "keys %{$dt})",
                        ')',
                    ),
                },
            );
        }
        delete $cd->{uclset}{"$which.restrict"};

        my $cdef;
        if ($which eq 'keys') {
            $cdef = $cd->{clset}{"keys.create_default"} // 1;
            delete $cd->{uclset}{"keys.create_default"};
        }

        #local $cd->{args}{return_type} = 'bool';
        my $nkeys = scalar(keys %$cv);
        my $i = 0;
        for my $k (sort keys %$cv) {
            my $kre = $c->_str2reliteral($cd, $k);
            local $cd->{spath} = [@{ $cd->{spath} }, $k];
            ++$i;
            my $sch = $c->main->normalize_schema($cv->{$k});
            my $kdn = $k; $kdn =~ s/\W+/_/g;
            my $klit = $which eq 're_keys' ? '$_' : $c->literal($k);
            my $kdt = "$dt\->{$klit}";
            my %iargs = %{$cd->{args}};
            $iargs{outer_cd}             = $cd;
            $iargs{data_name}            = $kdn;
            $iargs{data_term}            = $kdt;
            $iargs{schema}               = $sch;
            $iargs{schema_is_normalized} = 1;
            $iargs{indent_level}++;
            my $icd = $c->compile(%iargs);

            # should we set default for hash value?
            my $sdef = $cdef && defined($sch->[1]{default});

            # stack is used to store (non-bool) subresults
            $c->add_var($cd, '_sahv_stack', []) if $use_dpath;

            my @code = (
                ($c->indent_str($cd), "(push(@\$_sahv_dpath, undef), push(\@\$_sahv_stack, undef), \$_sahv_stack->[-1] = \n")
                    x !!($use_dpath && $i == 1),

                # for re_keys, we iterate over all data's keys which match regex
                ('(!defined(List::Util::first(sub {!(')
                    x !!($which eq 're_keys'),

                $which eq 're_keys' ? "\$_ !~ /$kre/ || (" :
                    ($sdef ? "" : "!exists($kdt) || ("),

                ($c->indent_str($cd), "(\$_sahv_dpath->[-1] = ".
                     ($which eq 're_keys' ? '$_' : $klit)."),\n")
                         x !!$use_dpath,
                $icd->{result}, "\n",

                $which eq 're_keys' || !$sdef ? ")" : "",

                # close iteration over all data's keys which match regex
                (")}, sort keys %{ $dt })))")
                    x !!($which eq 're_keys'),

                ($c->indent_str($cd), "), (pop \@\$_sahv_dpath), pop(\@\$_sahv_stack)\n")
                    x !!($use_dpath && $i == $nkeys),
            );
            my $ires = join("", @code);
            local $cd->{_debug_ccl_note} = "$which: ".$c->literal($k);
            $c->add_ccl($cd, $ires);
        }
        $jccl = $c->join_ccls(
            $cd, $cd->{ccls}, {err_msg => ''});
    }
    $c->add_ccl($cd, $jccl, {});
}

sub clause_keys {
    my ($self, $cd) = @_;
    $self->_clause_keys_or_re_keys('keys', $cd);
}

sub clause_re_keys {
    my ($self, $cd) = @_;
    $self->_clause_keys_or_re_keys('re_keys', $cd);
}

sub clause_req_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    # we assign to $h first to avoid variable clashing if $dt is '$_'.

    $c->add_module($cd, "List::Util");
    $c->add_ccl(
      $cd,
      "do { my \$h = $dt; !defined(List::Util::first(sub {!exists(\$h\->{\$_})}, \@{ $ct })) }",
      {
        err_msg => 'TMP',
        err_expr =>
          "sprintf(".
          $c->literal($c->_xlt($cd, "hash has missing required field(s) (%s)")).
          ",join(', ', do { my \$h = $dt; grep { !exists(\$h\->{\$_}) } \@{ $ct } }))"
      }
    );
}

sub clause_allowed_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    $c->add_module($cd, "List::Util");
    $c->add_smartmatch_pragma($cd);
    $c->add_ccl(
      $cd,
      "!defined(List::Util::first(sub {!(\$_ ~~ $ct)}, keys \%{ $dt }))",
      {
        err_msg => 'TMP',
        err_expr =>
          "sprintf(".
          $c->literal($c->_xlt($cd, "hash contains non-allowed field(s) (%s)")).
          ",join(', ', sort grep { !(\$_ ~~ $ct) } keys \%{ $dt }))"
      }
    );
}

sub clause_allowed_keys_re {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    #my $ct = $cd->{cl_term};
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        # i'm lazy atm and does not need expr yet
        $c->_die_unimplemented_clause($cd, "with expr");
    }

    my $re = $c->_str2reliteral($cd, $cv);
    $c->add_module($cd, "List::Util");
    $c->add_smartmatch_pragma($cd);
    $c->add_ccl(
        $cd,
        "!defined(List::Util::first(sub {\$_ !~ /$re/}, keys \%{ $dt }))",
        {
          err_msg => 'TMP',
          err_expr =>
          "sprintf(".
          $c->literal($c->_xlt($cd, "hash contains non-allowed field(s) (%s)")).
          ",join(', ', sort grep { \$_ !~ /$re/ } keys \%{ $dt }))"
      }
    );
}

sub clause_forbidden_keys {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    $c->add_module($cd, "List::Util");
    $c->add_smartmatch_pragma($cd);
    $c->add_ccl(
      $cd,
      "!defined(List::Util::first(sub {\$_ ~~ $ct}, keys \%{ $dt }))",
      {
        err_msg => 'TMP',
        err_expr =>
          "sprintf(".
          $c->literal($c->_xlt($cd, "hash contains forbidden field(s) (%s)")).
          ",join(', ', sort grep { \$_ ~~ $ct } keys \%{ $dt }))"
      }
    );
}

sub clause_forbidden_keys_re {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    #my $ct = $cd->{cl_term};
    my $cv = $cd->{cl_value};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        # i'm lazy atm and does not need expr yet
        $c->_die_unimplemented_clause($cd, "with expr");
    }

    my $re = $c->_str2reliteral($cd, $cv);
    $c->add_module($cd, "List::Util");
    $c->add_smartmatch_pragma($cd);
    $c->add_ccl(
        $cd,
        "!defined(List::Util::first(sub {\$_ =~ /$re/}, keys \%{ $dt }))",
        {
          err_msg => 'TMP',
          err_expr =>
          "sprintf(".
          $c->literal($c->_xlt($cd, "hash contains forbidden field(s) (%s)")).
          ",join(', ', sort grep { \$_ =~ /$re/ } keys \%{ $dt }))"
      }
    );
}

1;
# ABSTRACT: perl's type handler for type "hash"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::perl::TH::hash - perl's type handler for type "hash"

=head1 VERSION

This document describes version 0.41 of Data::Sah::Compiler::perl::TH::hash (from Perl distribution Data-Sah), released on 2015-01-06.

=for Pod::Coverage ^(clause_.+|superclause_.+)$

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Data-Sah>.

=head1 SOURCE

Source repository is at L<https://github.com/perlancar/perl-Data-Sah>.

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
