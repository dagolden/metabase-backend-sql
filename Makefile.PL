use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.17;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Metabase backend role for SQL-based backends",
  "AUTHOR" => "David Golden <dagolden\@cpan.org>, Leon Brocard <acme\@astray.org>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.17"
  },
  "DISTNAME" => "Metabase-Backend-SQL",
  "LICENSE" => "apache",
  "MIN_PERL_VERSION" => "5.010",
  "NAME" => "Metabase::Backend::SQL",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Class::Load" => 0,
    "Compress::Zlib" => 2,
    "DBD::SQLite" => 0,
    "DBI" => 1,
    "DBIx::RunSQL" => 0,
    "DBIx::Simple" => 0,
    "Data::Stream::Bulk::Array" => 0,
    "Data::Stream::Bulk::Callback" => 0,
    "Data::Stream::Bulk::DBI" => 0,
    "Data::Stream::Bulk::Filter" => 0,
    "Data::Stream::Bulk::Nil" => 0,
    "File::Temp" => 0,
    "JSON" => 2,
    "List::AllUtils" => 0,
    "List::Util" => 0,
    "Metabase::Archive" => 1,
    "Metabase::Fact" => 0,
    "Metabase::Index" => 1,
    "Moose" => 0,
    "Moose::Role" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "MooseX::Types::Path::Class" => 0,
    "SQL::Abstract" => 0,
    "SQL::Translator" => "0.11006",
    "SQL::Translator::Diff" => 0,
    "SQL::Translator::Schema" => 0,
    "SQL::Translator::Schema::Constants" => 0,
    "SQL::Translator::Utils" => 0,
    "Storable" => 0,
    "Try::Tiny" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "File::Spec::Functions" => 0,
    "Path::Class" => 0,
    "Test::Deep" => 0,
    "Test::Fatal" => 0,
    "Test::More" => "0.92",
    "Test::Routine" => 0,
    "Test::Routine::Util" => 0,
    "lib" => 0,
    "re" => 0
  },
  "VERSION" => "1.002",
  "test" => {
    "TESTS" => "t/*.t t/postgres/*.t t/sharded/*.t t/sqlite/*.t"
  }
);


my %FallbackPrereqs = (
  "Carp" => 0,
  "Class::Load" => 0,
  "Compress::Zlib" => 2,
  "DBD::SQLite" => 0,
  "DBI" => 1,
  "DBIx::RunSQL" => 0,
  "DBIx::Simple" => 0,
  "Data::Stream::Bulk::Array" => 0,
  "Data::Stream::Bulk::Callback" => 0,
  "Data::Stream::Bulk::DBI" => 0,
  "Data::Stream::Bulk::Filter" => 0,
  "Data::Stream::Bulk::Nil" => 0,
  "ExtUtils::MakeMaker" => 0,
  "File::Spec" => 0,
  "File::Spec::Functions" => 0,
  "File::Temp" => 0,
  "JSON" => 2,
  "List::AllUtils" => 0,
  "List::Util" => 0,
  "Metabase::Archive" => 1,
  "Metabase::Fact" => 0,
  "Metabase::Index" => 1,
  "Moose" => 0,
  "Moose::Role" => 0,
  "Moose::Util::TypeConstraints" => 0,
  "MooseX::Types::Path::Class" => 0,
  "Path::Class" => 0,
  "SQL::Abstract" => 0,
  "SQL::Translator" => "0.11006",
  "SQL::Translator::Diff" => 0,
  "SQL::Translator::Schema" => 0,
  "SQL::Translator::Schema::Constants" => 0,
  "SQL::Translator::Utils" => 0,
  "Storable" => 0,
  "Test::Deep" => 0,
  "Test::Fatal" => 0,
  "Test::More" => "0.92",
  "Test::Routine" => 0,
  "Test::Routine::Util" => 0,
  "Try::Tiny" => 0,
  "lib" => 0,
  "namespace::autoclean" => 0,
  "re" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
