#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Schema::Result::Group;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->load_components( 'Tree::NestedSet', 'InflateColumn::DateTime',
  'Core' );

__PACKAGE__->table("invgroup");
__PACKAGE__->add_columns(
  id => {
    data_type         => 'serial',
    is_auto_increment => 1,
    is_numeric        => 1,
  },
  name => {
    data_type   => 'varchar',
    size        => 150,
    is_nullable => 0,
  },
  root_id => {
    data_type   => 'integer',
    is_nullable => 1,
  },
  lft => {
    data_type   => 'integer',
    is_nullable => 0,
  },
  rgt => {
    data_type   => 'integer',
    is_nullable => 0,
  },
  level => {
    data_type   => 'integer',
    is_nullable => 0,
  },
  c_date => {
    data_type     => 'timestamp',
    is_nullable   => 0,
    default_value => \'CURRENT_TIMESTAMP',
  },
  m_date => {
    data_type     => 'timestamp',
    is_nullable   => 0,
    default_value => \'CURRENT_TIMESTAMP',
  },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->tree_columns(
  {
    root_column  => 'root_id',
    left_column  => 'lft',
    right_column => 'rgt',
    level_column => 'level',
  }
);

__PACKAGE__->has_many( "hardware",
  "Rex::IO::Server::Inventory::Schema::Result::Hardware", "group_id" );

sub all_data {
  my $self = shift;

  return {
    id       => $self->id,
    name     => ( $self->name // "no-name" ),
    text     => ( $self->name // "no-name" ),
    c_date   => ( $self->c_date // "" ),
    m_date   => ( $self->m_date // "" ),
    children => ( $self->is_leaf ? Mojo::JSON->false : Mojo::JSON->true ),
    state    => {
      opened   => Mojo::JSON->false,
      disabled => Mojo::JSON->false,
      selected => Mojo::JSON->false,
    },
  };
}

1;
