#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Schema::Result::Hardware;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->load_components( 'InflateColumn::Serializer',
  'InflateColumn::DateTime', 'Core' );

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
  permission_set_id => {
    data_type   => 'integer',
    is_numeric  => 1,
    is_nullable => 1,
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
  data => {
    data_type        => 'json',
    is_nullable      => 1,
    serializer_class => 'JSON',
  },
);

__PACKAGE__->set_primary_key("id");

sub all_data {
  my $self = shift;

  return {
    name              => $self->name,
    c_date            => $self->c_date,
    m_date            => $self->m_date,
    permission_set_id => $self->permission_set_id,
    data              => $self->data,
  };
}

1;
