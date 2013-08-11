use strict;
use warnings;

# This test was generated via Dist::Zilla::Plugin::Test::Compile 2.018

use Test::More 0.88;



use Capture::Tiny qw{ capture };

my @module_files = qw(
Data/Sah.pm
Data/Sah/Compiler.pm
Data/Sah/Compiler/Prog.pm
Data/Sah/Compiler/Prog/TH.pm
Data/Sah/Compiler/Prog/TH/all.pm
Data/Sah/Compiler/Prog/TH/any.pm
Data/Sah/Compiler/TH.pm
Data/Sah/Compiler/TextResultRole.pm
Data/Sah/Compiler/human.pm
Data/Sah/Compiler/human/TH.pm
Data/Sah/Compiler/human/TH/Comparable.pm
Data/Sah/Compiler/human/TH/HasElems.pm
Data/Sah/Compiler/human/TH/Sortable.pm
Data/Sah/Compiler/human/TH/all.pm
Data/Sah/Compiler/human/TH/any.pm
Data/Sah/Compiler/human/TH/array.pm
Data/Sah/Compiler/human/TH/bool.pm
Data/Sah/Compiler/human/TH/code.pm
Data/Sah/Compiler/human/TH/float.pm
Data/Sah/Compiler/human/TH/hash.pm
Data/Sah/Compiler/human/TH/int.pm
Data/Sah/Compiler/human/TH/num.pm
Data/Sah/Compiler/human/TH/obj.pm
Data/Sah/Compiler/human/TH/re.pm
Data/Sah/Compiler/human/TH/str.pm
Data/Sah/Compiler/js.pm
Data/Sah/Compiler/js/TH.pm
Data/Sah/Compiler/js/TH/all.pm
Data/Sah/Compiler/js/TH/any.pm
Data/Sah/Compiler/js/TH/array.pm
Data/Sah/Compiler/js/TH/bool.pm
Data/Sah/Compiler/js/TH/code.pm
Data/Sah/Compiler/js/TH/float.pm
Data/Sah/Compiler/js/TH/hash.pm
Data/Sah/Compiler/js/TH/int.pm
Data/Sah/Compiler/js/TH/num.pm
Data/Sah/Compiler/js/TH/obj.pm
Data/Sah/Compiler/js/TH/re.pm
Data/Sah/Compiler/js/TH/str.pm
Data/Sah/Compiler/perl.pm
Data/Sah/Compiler/perl/TH.pm
Data/Sah/Compiler/perl/TH/all.pm
Data/Sah/Compiler/perl/TH/any.pm
Data/Sah/Compiler/perl/TH/array.pm
Data/Sah/Compiler/perl/TH/bool.pm
Data/Sah/Compiler/perl/TH/code.pm
Data/Sah/Compiler/perl/TH/float.pm
Data/Sah/Compiler/perl/TH/hash.pm
Data/Sah/Compiler/perl/TH/int.pm
Data/Sah/Compiler/perl/TH/num.pm
Data/Sah/Compiler/perl/TH/obj.pm
Data/Sah/Compiler/perl/TH/re.pm
Data/Sah/Compiler/perl/TH/str.pm
Data/Sah/Lang.pm
Data/Sah/Lang/fr_FR.pm
Data/Sah/Lang/id_ID.pm
Data/Sah/Lang/zh_CN.pm
Data/Sah/Schema/Common.pm
Data/Sah/Schema/sah.pm
Data/Sah/Type/BaseType.pm
Data/Sah/Type/Comparable.pm
Data/Sah/Type/HasElems.pm
Data/Sah/Type/Sortable.pm
Data/Sah/Type/all.pm
Data/Sah/Type/any.pm
Data/Sah/Type/array.pm
Data/Sah/Type/bool.pm
Data/Sah/Type/buf.pm
Data/Sah/Type/code.pm
Data/Sah/Type/float.pm
Data/Sah/Type/hash.pm
Data/Sah/Type/int.pm
Data/Sah/Type/num.pm
Data/Sah/Type/obj.pm
Data/Sah/Type/re.pm
Data/Sah/Type/str.pm
Data/Sah/Type/undef.pm
Data/Sah/Util/Func.pm
Data/Sah/Util/Role.pm
Data/Sah/Util/TypeX.pm
);

my @scripts = qw(

);

# no fake home requested

my @warnings;
for my $lib (@module_files)
{
    my ($stdout, $stderr, $exit) = capture {
        system($^X, '-Mblib', '-e', qq{require q[$lib]});
    };
    is($?, 0, "$lib loaded ok");
    warn $stderr if $stderr;
    push @warnings, $stderr if $stderr;
}



is(scalar(@warnings), 0, 'no warnings found') if $ENV{AUTHOR_TESTING};



done_testing;
