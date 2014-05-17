package Data::Sah::Compiler::js::TH::str;

use 5.010;
use Log::Any '$log';
use Moo;
extends 'Data::Sah::Compiler::js::TH';
with 'Data::Sah::Type::str';

our $VERSION = '0.28'; # VERSION

sub handle_type {
    my ($self, $cd) = @_;
    my $c = $self->compiler;

    my $dt = $cd->{data_term};
    $cd->{_ccl_check_type} = "typeof($dt)=='string' || typeof($dt)=='number'";
}

sub before_all_clauses {
    my ($self, $cd) = @_;
    my $c = $self->compiler;
    my $dt = $cd->{data_term};

    # XXX only do this when there are clauses

    # convert number to string
    $self->set_tmp_data_term($cd, "typeof($dt)=='number' ? ''+$dt : $dt");
}

sub after_all_clauses {
    my ($self, $cd) = @_;
    my $c = $self->compiler;
    my $dt = $cd->{data_term};

    $self->restore_data_term($cd);
}

sub superclause_comparable {
    my ($self, $which, $cd) = @_;
    my $c  = $self->compiler;
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'is') {
        $c->add_ccl($cd, "$dt == $ct");
    } elsif ($which eq 'in') {
        $c->add_ccl($cd, "($ct).indexOf($dt) > -1");
    }
}

sub superclause_sortable {
    my ($self, $which, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'min') {
        $c->add_ccl($cd, "$dt >= $ct");
    } elsif ($which eq 'xmin') {
        $c->add_ccl($cd, "$dt > $ct");
    } elsif ($which eq 'max') {
        $c->add_ccl($cd, "$dt <= $ct");
    } elsif ($which eq 'xmax') {
        $c->add_ccl($cd, "$dt < $ct");
    } elsif ($which eq 'between') {
        if ($cd->{cl_is_expr}) {
            $c->add_ccl($cd, "$dt >= ($ct)[0] && $dt <= ($ct)[1]");
        } else {
            # simplify code
            $c->add_ccl($cd, "$dt >= ".$c->literal($cv->[0]).
                            " && $dt <= ".$c->literal($cv->[1]));
        }
    } elsif ($which eq 'xbetween') {
        if ($cd->{cl_is_expr}) {
            $c->add_ccl($cd, "$dt > ($ct)[0] && $dt < ($ct)[1]");
        } else {
            # simplify code
            $c->add_ccl($cd, "$dt > ".$c->literal($cv->[0]).
                            " && $dt < ".$c->literal($cv->[1]));
        }
    }
}

sub superclause_has_elems {
    my ($self_th, $which, $cd) = @_;
    my $c  = $self_th->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'len') {
        $c->add_ccl($cd, "($dt).length == $ct");
    } elsif ($which eq 'min_len') {
        $c->add_ccl($cd, "($dt).length >= $ct");
    } elsif ($which eq 'max_len') {
        $c->add_ccl($cd, "($dt).length <= $ct");
    } elsif ($which eq 'len_between') {
        if ($cd->{cl_is_expr}) {
            $c->add_ccl(
                $cd, "($dt).length >= ($ct)[0] && ".
                    "($dt).length >= ($ct)[1]");
        } else {
            # simplify code
            $c->add_ccl(
                $cd, "($dt).length >= $cv->[0] && ".
                    "($dt).length <= $cv->[1]");
        }
    } elsif ($which eq 'has') {
        $c->add_ccl($cd, "($dt).indexOf($ct) > -1");
    } elsif ($which eq 'each_index' || $which eq 'each_elem') {
        $self_th->gen_each($which, $cd,
                           $c->expr_array_0_nmin1("($dt).length"),
                           "($dt).split('')");
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

sub clause_match {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    my $re;
    if ($cd->{cl_is_expr}) {
        $re = $ct;
    } else {
        $re = $c->_str2reliteral($cd, $cv);
    }

    $c->add_ccl($cd, join(
        "",
        "(function(){ ",
        "var _sahv_match = true; ",
        "try { _sahv_match = ($dt).match(RegExp($re)) } catch(e) { if (e.name=='SyntaxError') _sahv_match = false } ",
        ($cd->{cl_is_expr} ?
             "return _sahv_match == !!($ct);" :
                 "return ".($cv ? '':'!')."!!_sahv_match;"),
        "} )()",
    ));
}

sub clause_is_re {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    $c->add_ccl($cd, join(
        "",
        "(function(){ var _sahv_is_re = true; ",
        "try { RegExp($dt) } catch(e) { if (e.name=='SyntaxError') _sahv_is_re = false } ",
        ($cd->{cl_is_expr} ?
            "return _sahv_is_re == !!($ct);" :
                "return ".($cv ? '':'!')."_sahv_is_re;"),
        "} )()",
    ));
}

1;
# ABSTRACT: js's type handler for type "str"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::js::TH::str - js's type handler for type "str"

=head1 VERSION

This document describes version 0.28 of Data::Sah::Compiler::js::TH::str (from Perl distribution Data-Sah), released on 2014-05-17.

=for Pod::Coverage ^(clause_.+|superclause_.+|handle_.+|before_.+|after_.+)$

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
