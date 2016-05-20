package Rex::IO::Server::Inventory;
use Mojo::Base 'Mojolicious';

use Rex::IO::Server::Inventory::Schema;

has schema => sub {
    my ($self) = @_;

    my $dsn;

    if ( exists $self->config->{database}->{dsn} ) {
        $dsn = $self->config->{database}->{dsn};
    }
    else {
        $dsn =
            "dbi:"
          . $self->config->{database}->{type} . ":"
          . "database="
          . $self->config->{database}->{schema} . ";" . "host="
          . $self->config->{database}->{host};
    }

    return Rex::IO::Server::Inventory::Schema->connect(
        $dsn,
        ( $self->config->{database}->{username} || "" ),
        ( $self->config->{database}->{password} || "" ),
        ( $self->config->{database}->{options}  || {} ),
    );
};

# This method will run once at server start
sub startup {
    my $self = shift;

    my $ua = $self->ua;

    $self->helper( db => sub { $self->app->schema } );

    #######################################################################
    # Load configuration
    #######################################################################
    my @cfg = (
        "inventory_server.conf",
        "/etc/rex/io/inventory_server.conf",
        "/usr/local/etc/rex/io/inventory_server.conf",
    );
    my $cfg;
    for my $file (@cfg) {
        if ( -f $file ) {
            $cfg = $file;
            last;
        }
    }

    #######################################################################
    # Load plugins
    #######################################################################
    $self->plugin( "Config", file => $cfg );

    #######################################################################
    # routes
    #######################################################################
    my $r = $self->routes;
    $r->post('/register')->to('main#register_plugin');

    # get all assets
    $r->get('/inventory/:group_id')->to('main#read_all');

    # assets
    $r->get('/inventory/:hw_id')->to('main#read');
    $r->post('/inventory')->to('main#create');
    $r->put('/inventory/:hw_id')->to('main#update');
    $r->delete('/inventory/:hw_id')->to('main#remove');

    # property
    $r->get('/inventory/:hw_id/property/:prop_id')->to('property#read');
    $r->post('/inventory/:hw_id/property')->to('property#create');
    $r->put('/inventory/:hw_id/property/:prop_id')->to('property#update');
    $r->delete('/inventory/:hw_id/property/:prop_id')->to('property#remove');

    # group
    $r->get('/group/root')->to('group#read_root');
    $r->get('/group/:group_id/children')->to('group#get_children');

    $r->get('/group/:group_id')->to('group#read');
    $r->post('/group')->to('group#create');
    $r->put('/group/:group_id')->to('group#update');
    $r->delete('/group/:group_id')->to('group#remove');

    # templates
    $r->get('/template/:template_id')->to('template#read');
    $r->post('/template/:template_id')->to('template#create');
    $r->put('/template/:template_id')->to('template#update');
    $r->delete('/template/:template_id')->to('template#remove');

}

1;
