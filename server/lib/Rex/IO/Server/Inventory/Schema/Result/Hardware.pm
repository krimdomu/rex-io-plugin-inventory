#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Schema::Result::Hardware;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->load_components( 'InflateColumn::DateTime', 'Core' );

__PACKAGE__->table("hardware");
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
  type => {
    data_type   => 'varchar',
    size        => 50,
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

__PACKAGE__->has_many( "properties",
  "Rex::IO::Server::Inventory::Schema::Result::Property",
  "hardware_id" );

sub all_data {
  my $self = shift;

  my @properties;
  my $prop_rs = $self->properties();
  while ( my $prop = $prop_rs->next ) {
    push @properties, { name => $prop->name, value => $prop->value };
  }

  return {
    id         => $self->id,
    name       => ( $self->name // "no-name" ),
    type       => ( $self->type // "" ),
    c_date     => ( $self->c_date // "" ),
    m_date     => ( $self->m_date // "" ),
    properties => \@properties,
  };
}

1;
