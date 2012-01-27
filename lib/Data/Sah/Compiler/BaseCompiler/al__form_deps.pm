package Data::Sah::Compiler::BaseCompiler;
{
  $Data::Sah::Compiler::BaseCompiler::VERSION = '0.02';
}

# split to delay loading modules

use 5.010;
use strict;
use warnings;

use Algorithm::Dependency::Ordered;
use Algorithm::Dependency::Source::HoA;
use Language::Expr::Interpreter::VarEnumer;

# form dependency list from which clauses are mentioned in expressions
sub _form_deps {
    my ($self, $ct) = @_;

    $self->main->_var_enumer(Language::Expr::Interpreter::VarEnumer->new)
        unless $self->main->_var_enumer;

    my %depends;
    for my $clause (values %$ct) {
        my $name = $clause->{name};
        my $expr = $clause->{name} eq 'check' ? $clause->{value} :
            $clause->{attrs}{expr};
        if (defined $expr) {
            my $vars = $self->_main->_var_enumer->eval($expr);
            for (@$vars) {
                /^\w+$/ or $self->_die(
                    "Invalid variable syntax `$_`, ".
                        "currently only the form \$abc is supported");
                $ct->{$_} or $self->_die(
                    "Unknown clause specified in variable '$_'");
            }
            $depends{$name} = $vars;
            for (@$vars) {
                push @{ $ct->{$_}{depended_by} }, $name;
            }
        } else {
            $depends{$name} = [];
        }
    }
    #$log->tracef("deps: %s", \%depends);
    my $ds = Algorithm::Dependency::Source::HoA->new(\%depends);
    my $ad = Algorithm::Dependency::Ordered->new(source => $ds)
        or die "Failed to set up dependency algorithm";
    my $sched = $ad->schedule_all
        or die "Can't resolve dependencies, please check your expressions";
    #$log->tracef("sched: %s", $sched);
    my %rsched = map
        {@{ $depends{$sched->[$_]} } ? ($sched->[$_] => $_) : ()}
            0..@$sched-1;
    #$log->tracef("deps: %s", \%rsched);
    \%rsched;
}

1;

__END__
=pod

=head1 NAME

Data::Sah::Compiler::BaseCompiler

=head1 VERSION

version 0.02

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

