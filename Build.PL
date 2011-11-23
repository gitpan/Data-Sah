
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  'build_requires' => {
    'Module::Build' => '0.3601'
  },
  'configure_requires' => {
    'Module::Build' => '0.3601'
  },
  'dist_abstract' => 'Schema for data structures',
  'dist_author' => [
    'Steven Haryanto <stevenharyanto@gmail.com>'
  ],
  'dist_name' => 'Data-Sah',
  'dist_version' => '0.01',
  'license' => 'perl',
  'module_name' => 'Data::Sah',
  'recommends' => {},
  'recursive_test_files' => 1,
  'requires' => {
    'Algorithm::Dependency' => '0',
    'Data::Clone' => '0',
    'Data::Dump::OneLine' => '0.02',
    'Data::ModeMerge' => '0.21',
    'DateTime' => '0',
    'DateTime::Format::ISO8601' => '0',
    'Digest::MD5' => '0',
    'File::chdir' => '0',
    'Language::Expr' => '0.13',
    'List::MoreUtils' => '0',
    'Log::Any' => '0.09',
    'Moo' => '0',
    'Regexp::Grammars' => '0',
    'Scalar::Util' => '0',
    'Sub::Install' => '0',
    'Test::Aggregate' => '0',
    'Test::Exception' => '0',
    'Test::More' => '0.96',
    'URI::Escape' => '0',
    'YAML::Syck' => '0',
    'boolean' => '0',
    'perl' => '5.010000'
  },
  'script_files' => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
