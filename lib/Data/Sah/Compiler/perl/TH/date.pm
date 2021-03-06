package Data::Sah::Compiler::perl::TH::date;

use 5.010;
use Log::Any '$log';
use Moo;
use experimental 'smartmatch';
extends 'Data::Sah::Compiler::perl::TH';
with 'Data::Sah::Type::date';

use Scalar::Util qw(blessed looks_like_number);

our $VERSION = '0.41'; # VERSION
our $DATE = '2015-01-06'; # DATE

sub expr_coerce_term {
    my ($self, $cd, $t) = @_;

    my $c = $self->compiler;
    $c->add_module($cd, 'DateTime');
    $c->add_module($cd, 'Scalar::Util');

    join(
        '',
        "(",
        "(Scalar::Util::blessed($t) && $t->isa('DateTime')) ? $t : ",
        "(Scalar::Util::looks_like_number($t) && $t >= 10**8 && $t <= 2**31) ? (DateTime->from_epoch(epoch=>$t)) : ",
        "$t =~ /\\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})Z\\z/ ? DateTime->new(year=>\$1, month=>\$2, day=>\$3, hour=>\$4, minute=>\$5, second=>\$6, time_zone=>'UTC') : ",
        "$t =~ /\\A([0-9]{4})-([0-9]{2})-([0-9]{2})\\z/ ? DateTime->new(year=>\$1, month=>\$2, day=>\$3) : die(\"BUG: can't coerce date\")",
        ")",
    );
}

sub expr_coerce_value {
    my ($self, $cd, $v) = @_;

    my $c = $self->compiler;
    $c->add_module($cd, 'DateTime');

    if (blessed($v) && $v->isa('DateTime')) {
        return join(
            '',
            "DateTime->new(",
            "year=>",   $v->year, ",",
            "month=>",  $v->month, ",",
            "day=>",    $v->day, ",",
            "hour=>",   $v->hour, ",",
            "minute=>", $v->minute, ",",
            "second=>", $v->second, ",",
            ")",
        );
    } elsif (looks_like_number($v) && $v >= 10**8 && $v <= 2**31) {
        return "DateTime->from_epoch(epoch=>$v)";
    } elsif ($v =~ /\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})Z\z/) {
        require DateTime;
        eval { DateTime->new(year=>$1, month=>$2, day=>$3,
                             hour=>$4, minute=>$5, second=>$6,
                             time_zone=>'UTC') ; 1 }
            or die "Invalid date literal '$v': $@";
        return "DateTime->new(year=>$1, month=>$2, day=>$3, hour=>$4, minute=>$5, second=>$6, time_zone=>'UTC')";
    } elsif ($v =~ /\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/) {
        require DateTime;
        eval { DateTime->new(year=>$1, month=>$2, day=>$3) ; 1 }
            or die "Invalid date literal '$v': $@";
        return "DateTime->new(year=>$1, month=>$2, day=>$3)";
    } else {
        die "Invalid date literal '$v'";
    }
}

sub handle_type {
    my ($self, $cd) = @_;
    my $c  = $self->compiler;
    my $dt = $cd->{data_term};

    $c->add_module($cd, 'Scalar::Util');
    $cd->{_ccl_check_type} = join(
        '',
        "(",
        "(Scalar::Util::blessed($dt) && $dt->isa('DateTime'))",
        " || ",
        "(Scalar::Util::looks_like_number($dt) && $dt >= 10**8 && $dt <= 2**31)",
        " || ",
        "($dt =~ /\\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})Z\\z/ && eval { DateTime->new(year=>\$1, month=>\$2, day=>\$3, hour=>\$4, minute=>\$5, second=>\$6, time_zone=>'UTC'); 1})",
        " || ",
        "($dt =~ /\\A([0-9]{4})-([0-9]{2})-([0-9]{2})\\z/ && eval { DateTime->new(year=>\$1, month=>\$2, day=>\$3); 1})",
        ")",
    );
}

sub before_all_clauses {
    my ($self, $cd) = @_;
    my $c = $self->compiler;
    my $dt = $cd->{data_term};

    # XXX only do this when there are clauses

    # coerce to DateTime object during validation
    $self->set_tmp_data_term($cd, $self->expr_coerce_term($cd, $dt));
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
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($which eq 'is') {
        if ($cd->{cl_is_expr}) {
            $ct = $self->expr_coerce_term($cd, $ct);
        } else {
            $ct = $self->expr_coerce_value($cd, $cv);
        }
        $c->add_ccl($cd, "DateTime->compare($dt, $ct)==0");
    } elsif ($which eq 'in') {
        $c->add_module('List::Util');
        if ($cd->{cl_is_expr}) {
            # i'm lazy, technical debt
            $c->_die($cd, "date's in clause with expression not yet supported");
        } else {
            $ct = join(', ', map { $self->expr_coerce_value($cd, $_) } @$cv);
        };
        $c->add_ccl($cd, "List::Util::first(sub{DateTime->compare($dt, \$_)==0}, $ct)");
    }
}

sub superclause_sortable {
    my ($self, $which, $cd) = @_;
    my $c  = $self->compiler;
    my $cv = $cd->{cl_value};
    my $ct = $cd->{cl_term};
    my $dt = $cd->{data_term};

    if ($cd->{cl_is_expr}) {
        # i'm lazy, technical debt
        $c->_die($cd, "date's comparison with expression not yet supported");
    }

    if ($which eq 'min') {
        $c->add_ccl($cd, "DateTime->compare($dt, ".
                        $self->expr_coerce_value($cd, $cv).") >= 0");
    } elsif ($which eq 'xmin') {
        $c->add_ccl($cd, "DateTime->compare($dt, ".
                        $self->expr_coerce_value($cd, $cv).") > 0");
    } elsif ($which eq 'max') {
        $c->add_ccl($cd, "DateTime->compare($dt, ".
                        $self->expr_coerce_value($cd, $cv).") <= 0");
    } elsif ($which eq 'xmax') {
        $c->add_ccl($cd, "DateTime->compare($dt, ".
                        $self->expr_coerce_value($cd, $cv).") < 0");
    } elsif ($which eq 'between') {
        $c->add_ccl($cd,
                    join(
                        '',
                        "DateTime->compare($dt, ",
                        $self->expr_coerce_value($cd, $cv->[0]).") >= 0 && ",
                        "DateTime->compare($dt, ",
                        $self->expr_coerce_value($cd, $cv->[1]).") <= 0",
                    ));
    } elsif ($which eq 'xbetween') {
        $c->add_ccl($cd,
                    join(
                        '',
                        "DateTime->compare($dt, ",
                        $self->expr_coerce_value($cd, $cv->[0]).") > 0 && ",
                        "DateTime->compare($dt, ",
                        $self->expr_coerce_value($cd, $cv->[1]).") < 0",
                    ));
    }
}

1;
# ABSTRACT: perl's type handler for type "date"

__END__

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Compiler::perl::TH::date - perl's type handler for type "date"

=head1 VERSION

This document describes version 0.41 of Data::Sah::Compiler::perl::TH::date (from Perl distribution Data-Sah), released on 2015-01-06.

=head1 DESCRIPTION

What constitutes a valid date value:

=over

=item * L<DateTime> object

=item * integers from 100 million to 2^31

For convenience, some integers are accepted and interpreted as Unix epoch (32
bit). They will be converted to DateTime objects during validation. The values
correspond to dates from Mar 3rd, 1973 to Jan 19, 2038 (Y2038).

Choosing 100 million (9 decimal digits) as the lower limit is to avoid parsing
numbers like 20141231 (8 digit) as YMD date.

=item * string in the form of "YYYY-MM-DD"

For convenience, string of this form, like C<2014-04-25> is accepted and will be
converted to DateTime object. Invalid dates like C<2014-04-31> will of course
fail the validation.

=item * string in the form of "YYYY-MM-DDThh:mm:ssZ"

This is the Zulu form of ISO8601 date+time.

=back

=for Pod::Coverage ^(clause_.+|superclause_.+|handle_.+|before_.+|after_.+|expr_coerce_.+)$

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
