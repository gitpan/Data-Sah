package Data::Sah::Schema::sah;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.24'; # VERSION

# commented temporarily, unfinished refactoring
1;
# ABSTRACT: Collection of schemas related to Sah

=pod

=encoding UTF-8

=head1 NAME

Data::Sah::Schema::sah - Collection of schemas related to Sah

=head1 VERSION

version 0.24

=head1 RELEASE DATE

2014-04-25

=head1 DESCRIPTION

Validate a schema.

=head1

* First form shortcuts.

* Parse

* Prefilters/postfilters must be valid expressions, functions must be
known.

* Attribute conlicts.

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

__END__
sub schemas {
    my $re_var_nameU   = '(?:[A-Za-z_][A-Za-z0-9_]*)'; # U = unanchored
    my $re_type_name   = '\A(?:'.$re_var_nameU.'::)*'.$re_var_nameU.'+\z';
    my $re_func_name   = '\A(?:'.$re_var_nameU.'::)*'.$re_var_nameU.'+\z';
    my $reu_var_name   = '(?:[A-Za-z_][A-Za-z0-9_]*)';
    my $re_clause_name = '\A(?:[a-z_][a-z0-9_]*)\z'; # no uppercase
    my $re_cattr_name  = '\A(?:'.$re_var_nameU.'\.)*'.$re_var_nameU.'+\z';
    my $re_clause_key  = ''; # XXX ':ATTR' or 'NAME' or 'NAME:ATTR'

    # R = has req=>1
    my $clause_setR = ['hash' => {
        keys_regex => $re_clause_key,
    }];

    my $str_schemaR = ['str*' => {

        # TODO: is_sah_str_shortcut
        #if => [not_match => $re_type_name, isa_sah_str_shortcut=>1],

        # for now, we don't support string shortcuts
        match => $re_type_name,
    }];

    # TODO: is_expr

    my $array_schemaR = ['array*' => {
        min_len    => 1,
        # the first clause set checks the type
        {
            elems => [$str_schemaR],
        },

        # the second clause set checks the clause set
        {
            # first we discard the type first
            prefilters => ['array_slice($_, 1)'],
            deps       => [
                # no clause sets, e.g. ['int']
                [[array => {len=>1}],
                 'any'], # do nothing, succeed

                # a single clause set, flattened in the array, but there are odd
                # number of elements, e.g. ['int', min=>1, 'max']
                [[array => {elems=>['str*'], check=>'array_len($_) % 2 != 0'}],
                 ['any', fail=>1,
                  err_msg=>'Odd number of elements in clause set']],

                # a single clause set, flattened in the array, with even number
                # of elements, e.g. ['int', min=>1, max=>10]
                [[array => {elems=>['str*']}],
                 $clause_setR],

                # otherwise, all elements must be a clause set
                 ['any',
                  [array => {of => $clause_setR}]],
            ] # END deps
        },

    }];

    # predeclare
    my $hash_schemaR = ['hash*' => undef];

    my $schema => ['any' => {
        of   => [qw/str array hash/],
        deps => [
            ['str*'   => $str_schemaR],
            ['array*' => $array_schemaR],
            ['hash*'  => $hash_schemaR],
        ],
    }];

    my $defR = ['hash*' => {
        keys_of   => ['str*' => {,
                                 # remove optional '?' suffix
                                 prefilters => [q(replace('[?]\z', '', $_))],
                                 match      => $re_type_name,
                             }],
        values_of => $schema,
    }];

    $hash_schemaR->[1] = {
        keys     => {
            type        => $str_schemaR,
            clause_sets => ['any*', {
                of   => [qw/hash array/],
                deps => [
                    ['hash*'  => $clause_setR],
                    ['array*' => ['array*' => {of => $clause_setR}]],
                ],
            }],
            def         => $defR,
        },
        req_keys => ['type'],
    };

    my $schema => ['any' => {
        of   => [qw/str array hash/],
        deps => [
            ['str*'   => $str_schema],
            ['array*' => $array_schema],
            ['hash*'  => $hash_schema],
        ],
    }];

    return {
        'sah::str_schema'   => $str_schema,
        'sah::array_schema' => $array_schema,
        'sah::hash_schema'  => $hash_schema,
        'sah::schema'       => $schema,
    {

    };
}

1;
