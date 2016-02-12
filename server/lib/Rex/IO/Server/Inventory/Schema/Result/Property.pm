#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Schema::Result::Property;

use strict;
use warnings;

use base qw(DBIx::Class::Core);

__PACKAGE__->load_components( 'InflateColumn::DateTime', 'Core' );

__PACKAGE__->table("property");
__PACKAGE__->add_columns(
    id => {
        data_type         => 'serial',
        is_auto_increment => 1,
        is_numeric        => 1,
    },
    hardware_id => {
        data_type   => 'integer',
        is_nullable => 0,
    },
    name => {
        data_type   => 'varchar',
        size        => 150,
        is_nullable => 0,
    },
    value => {
        data_type   => 'text',
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
    m_user => {
        data_type     => 'varchar',
        is_nullable   => 1,
        default_value => '',
    },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to( "hardware",
    "Rex::IO::Server::Inventory::Schema::Result::Hardware",
    "hardware_id" );

1;
