use 5.006;
use strict;
use warnings;

package Metabase::Archive::SQL;
# ABSTRACT: Metabase archive backend role for common SQL actions
# VERSION

use Moose::Role;
use Moose::Util::TypeConstraints;

use Carp        ();
use Compress::Zlib 2 qw(compress uncompress);
use DBI         1 ();
use DBIx::RunSQL;
use DBIx::Simple;
use Data::Stream::Bulk::Array;
use Data::Stream::Bulk::DBI;
use Data::Stream::Bulk::Filter;
use File::Temp ();
use JSON 2      ();
use List::AllUtils qw/uniq/;
use Metabase::Fact;
use SQL::Abstract;
use SQL::Translator 0.11006 (); # required for deploy()
use SQL::Translator::Diff;
use SQL::Translator::Schema;
use SQL::Translator::Utils qw/normalize_name/;
use Try::Tiny;

with 'Metabase::Backend::SQL';
with 'Metabase::Archive';

has 'compressed' => (
  is      => 'rw',
  isa     => 'Bool',
  default => 1,
);

has '_blob_type' => (
  is => 'ro',
  isa => 'Str',
  lazy_build => 1,
);

has _table_name => (
  is => 'ro',
  isa => 'Str',
  default => 'metabase_archive',
);

requires '_build__blob_type';

sub initialize {
  my ($self, @fact_classes) = @_;
  my $schema = $self->schema;
  my $table = SQL::Translator::Schema::Table->new( name => $self->_table_name );
  $table->add_field( name => 'guid', data_type => 'char', size => 16 );
  $table->add_field( name => 'fact', data_type => $self->_blob_type );
  $schema->add_table($table);
  $self->_deploy_schema;
  return;
}

sub _packed_guid {
  my ($self, $guid) = @_;
  (my $clean_guid = $guid) =~ s{-}{}g;
  return pack("H*",$clean_guid);
}

# given fact, store it and return guid; return
# XXX can we store a fact with a GUID already?  Replaces?  Or error?
# here assign only if no GUID already
sub store {
  my ( $self, $fact_struct ) = @_;
  my $guid = lc $fact_struct->{metadata}{core}{guid};

  unless ($guid) {
    Carp::confess "Can't store: no GUID set for fact\n";
  }

  # remove any metadata that can be regenerated
  my $fact = {
    content => $fact_struct->{content},
    metadata => { core => $fact_struct->{metadata}{core} },
  };

  my $json = eval { JSON->new->utf8->encode($fact) };
  Carp::confess "Couldn't convert to JSON: $@"
  unless $json;

  if ( $self->compressed ) {
    $json    = compress($json);
  }


  try {
    $self->dbis->begin_work();
    $self->dbis->insert($self->_table_name, {
        guid => $self->_packed_guid($guid),
        fact => $json,
      });
    $self->dbis->commit;
  }
  catch {
    $self->dbis->rollback;
    Carp::confess("Error inserting record: $_");
  };

  return $guid;
}

# given guid, retrieve it and return it
# type is directory path
# class isa Metabase::Fact::Subclass
sub extract {
  my ( $self, $guid ) = @_;
  my $rs = $self->dbis->select($self->_table_name, 'fact', {
    guid => $self->_packed_guid($guid)
  });
  return $self->_extract_fact($rs->fetch->[0]);
}

sub _extract_fact {
  my ($self, $json) = @_;
  return undef unless $json;

  if ( $self->compressed ) {
    $json    = uncompress($json);
  }

  my $fact = eval { JSON->new->utf8->decode($json) };
  Carp::confess "Couldn't convert from JSON: $@"
    unless $fact;

  return $fact;
}

sub delete {
  my ( $self, $guid ) = @_;

  my $rs;
  try {
    $self->dbis->begin_work();
    $rs = $self->dbis->delete($self->_table_name, {
      guid => $self->_packed_guid($guid)
    });
    $self->dbis->commit;
  }
  catch {
    $self->dbis->rollback;
    Carp::confess("Error deleting record: $_");
  };

  return $rs->rows;
}

sub iterator {
  my ($self) = @_;
  my $rs = $self->dbis->select($self->_table_name, 'fact'); # everything

  my $dbi_stream = Data::Stream::Bulk::Array->new(
    array => scalar $rs->arrays,
  );

  return Data::Stream::Bulk::Filter->new(
    stream => $dbi_stream,
    filter => sub {
      my $block = shift;
      return [ map { $self->_extract_fact($_->[0]) } @$block ];
    },
  );
}

1;

__END__

=for Pod::Coverage::TrustPod store extract delete iterator initialize

=head1 SYNOPSIS

  package Metabase::Archive::SQLite;

  use Moose;

  with 'Metabase::Archive::SQL';

  # implement required fields
  ...;

  1;

=head1 DESCRIPTION

This is a role that implements the L<Metabase::Archive> role generically for an
SQL backend.  RDBMS vendor specific methods must be implemented by a Moose
class consuming this role.

The following methods must be implemented:

  _build_dsn        # a DSN string for DBI
  _build_db_user    # a username for DBI
  _build_db_pass    # a password for DBI
  _build_db_type    # a SQL::Translator type for the DB vendor
  _build_typemap    # hashref of metadata types to schema data types
  _build__blob_type        # data type for fact blob (compressed JSON)

=cut
