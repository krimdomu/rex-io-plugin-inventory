#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Schema::Result::Template;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->load_components( 'Tree::NestedSet', 'InflateColumn::DateTime',
  'Core' );

__PACKAGE__->table("template");
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
    default     => 'no-name',
  },
  type => {
    data_type   => 'varchar',
    size        => 150,
    is_nullable => 0,
  },
  content => {
    data_type   => 'text',
    default     => '',
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
);

__PACKAGE__->set_primary_key("id");

sub all_data {
  my $self = shift;

  return {
    id      => $self->id,
    name    => ( $self->name // "no-name" ),
    type    => ( $self->type // "plain" ),
    content => ( $self->content // "" ),
    c_date  => ( $self->c_date // "" ),
    m_date  => ( $self->m_date // "" ),
  };
}

1;
