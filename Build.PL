
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::ShareDir::Tarball" => 0,
    "File::chdir" => 0,
    "Module::Build" => "0.3601",
    "Sah" => "v0.9.19",
    "Test::Exception" => 0,
    "Test::More" => "0.98",
    "Test::Warn" => 0,
    "YAML::Syck" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Schema for data structures (Perl implementation)",
  "dist_author" => [
    "Steven Haryanto <stevenharyanto\@gmail.com>"
  ],
  "dist_name" => "Data-Sah",
  "dist_version" => "0.09",
  "license" => "perl",
  "module_name" => "Data::Sah",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Algorithm::Dependency::Ordered" => 0,
    "Algorithm::Dependency::Source::HoA" => 0,
    "Data::ModeMerge" => "0.21",
    "JSON" => 0,
    "Language::Expr" => "0.13",
    "Language::Expr::Interpreter::VarEnumer" => "0.13",
    "Log::Any" => "0.09",
    "Moo" => 0,
    "Moo::Role" => 0,
    "SHARYANTO::String::Util" => 0,
    "Sub::Install" => 0,
    "perl" => "5.010001"
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
