
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
    "Data::Clean::JSON" => "0.11",
    "Data::ModeMerge" => "0.21",
    "File::Which" => 0,
    "JSON" => 0,
    "Language::Expr" => "0.13",
    "Language::Expr::Interpreter::VarEnumer" => "0.13",
    "Lingua::EN::Numbers::Ordinate" => "1.02",
    "Log::Any" => "0.09",
    "Module::Path" => "0.08",
    "Moo" => 0,
    "Moo::Role" => 0,
    "SHARYANTO::String::Util" => 0,
    "SHARYANTO::Version::Util" => "0.64",
    "Sub::Install" => 0,
    "Text::sprintfn" => 0,
    "Tie::IxHash" => 0,
    "experimental" => 0
  },
  "TEST_REQUIRES" => {
    "Data::Dump::OneLine" => 0,
    "File::ShareDir" => 0,
    "File::ShareDir::Tarball" => 0,
    "File::Slurp" => 0,
    "File::Spec" => 0,
    "File::chdir" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Sah" => "v0.9.30",
    "Test::Exception" => 0,
    "Test::More" => "0.98",
    "Test::Warn" => 0
  },
  "VERSION" => "0.20",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Algorithm::Dependency::Ordered" => 0,
  "Algorithm::Dependency::Source::HoA" => 0,
  "Data::Clean::JSON" => "0.11",
  "Data::Dump::OneLine" => 0,
  "Data::ModeMerge" => "0.21",
  "File::ShareDir" => 0,
  "File::ShareDir::Tarball" => 0,
  "File::Slurp" => 0,
  "File::Spec" => 0,
  "File::Which" => 0,
  "File::chdir" => 0,
  "IO::Handle" => 0,
  "IPC::Open3" => 0,
  "JSON" => 0,
  "Language::Expr" => "0.13",
  "Language::Expr::Interpreter::VarEnumer" => "0.13",
  "Lingua::EN::Numbers::Ordinate" => "1.02",
  "Log::Any" => "0.09",
  "Module::Path" => "0.08",
  "Moo" => 0,
  "Moo::Role" => 0,
  "SHARYANTO::String::Util" => 0,
  "SHARYANTO::Version::Util" => "0.64",
  "Sah" => "v0.9.30",
  "Sub::Install" => 0,
  "Test::Exception" => 0,
  "Test::More" => "0.98",
  "Test::Warn" => 0,
  "Text::sprintfn" => 0,
  "Tie::IxHash" => 0,
  "experimental" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



