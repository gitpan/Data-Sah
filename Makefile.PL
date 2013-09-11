
use strict;
use warnings;

use 5.010001;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Fast and featureful data structure validation",
  "AUTHOR" => "Steven Haryanto <stevenharyanto\@gmail.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Data-Sah",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Data::Sah",
  "PREREQ_PM" => {
    "Algorithm::Dependency::Ordered" => 0,
    "Algorithm::Dependency::Source::HoA" => 0,
    "Data::Clean::JSON" => 0,
    "Data::ModeMerge" => "0.21",
    "JSON" => 0,
    "Language::Expr" => "0.13",
    "Language::Expr::Interpreter::VarEnumer" => "0.13",
    "Lingua::EN::Numbers::Ordinate" => "1.02",
    "Log::Any" => "0.09",
    "Module::Path" => "0.08",
    "Moo" => 0,
    "Moo::Role" => 0,
    "SHARYANTO::String::Util" => 0,
    "Sub::Install" => 0,
    "Text::sprintfn" => 0,
    "Tie::IxHash" => 0,
    "experimental" => 0
  },
  "TEST_REQUIRES" => {
    "Data::Dump::OneLine" => 0,
    "File::ShareDir::Tarball" => 0,
    "File::Slurp" => 0,
    "File::Which" => 0,
    "File::chdir" => 0,
    "Sah" => "v0.9.25",
    "Test::Exception" => 0,
    "Test::More" => "0.98",
    "Test::Warn" => 0
  },
  "VERSION" => "0.18",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



