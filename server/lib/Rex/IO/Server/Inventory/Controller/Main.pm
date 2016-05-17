#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Controller::Main;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;
use Data::Dumper;
use DateTime;

sub register_plugin {
    my $self          = shift;
    my $rex_io_server = $self->config->{rex_io}->{server};
    my $my_domain     = $self->config->{rex_io}->{self};
    my $ua            = $self->ua;

    my $register_conf = {
        name    => "inventory",
        methods => [
            {
                url      => "/inventory",
                meth     => "POST",
                auth     => Mojo::JSON->false,
                location => "$my_domain/inventory",
            },
            {
                url      => "/inventory/:group_id",
                meth     => "GET",
                auth     => Mojo::JSON->false,
                location => "$my_domain/inventory/:group_id",
            },
            {
                url      => "/inventory/:hw_id",
                meth     => "GET",
                auth     => Mojo::JSON->false,
                location => "$my_domain/inventory/:hw_id",
            },
            {
                url      => "/inventory/:hw_id",
                meth     => "DELETE",
                auth     => Mojo::JSON->true,
                location => "$my_domain/inventory/:hw_id",
            },
            {
                url      => "/inventory/:hw_id",
                meth     => "PUT",
                auth     => Mojo::JSON->false,
                location => "$my_domain/inventory/:hw_id",
            },

            # property
            {
                url      => "/inventory/:hw_id/property",
                meth     => "POST",
                auth     => Mojo::JSON->true,
                location => "$my_domain/inventory/:hw_id/property",
            },
            {
                url      => "/inventory/:hw_id/property/:prop_id",
                meth     => "GET",
                auth     => Mojo::JSON->true,
                location => "$my_domain/inventory/:hw_id/property/:prop_id",
            },
            {
                url      => "/inventory/:hw_id/property/:prop_id",
                meth     => "PUT",
                auth     => Mojo::JSON->true,
                location => "$my_domain/inventory/:hw_id/property/:prop_id",
            },
            {
                url      => "/inventory/:hw_id/property/:prop_id",
                meth     => "DELETE",
                auth     => Mojo::JSON->true,
                location => "$my_domain/inventory/:hw_id/property/:prop_id",
            },

            # group
            {
                url      => "/group",
                meth     => "POST",
                auth     => Mojo::JSON->true,
                location => "$my_domain/group",
            },
            {
                url      => "/group/root",
                meth     => "GET",
                auth     => Mojo::JSON->true,
                location => "$my_domain/group/root",
            },
            {
                url      => "/group/:group_id/children",
                meth     => "GET",
                auth     => Mojo::JSON->true,
                location => "$my_domain/group/:group_id/children",
            },
            {
                url      => "/group/:group_id",
                meth     => "GET",
                auth     => Mojo::JSON->true,
                location => "$my_domain/group/:group_id",
            },
            {
                url      => "/group/:group_id",
                meth     => "PUT",
                auth     => Mojo::JSON->true,
                location => "$my_domain/group/:group_id",
            },
            {
                url      => "/group/:group_id",
                meth     => "DELETE",
                auth     => Mojo::JSON->true,
                location => "$my_domain/group/:group_id",
            },
        ],
    };

    my $tx =
      $ua->post( "$rex_io_server/1.0/plugin/plugin", json => $register_conf );

    $self->render( json => $tx->res->json );
}

sub create {
    my $self = shift;
    $self->app->log->debug("Got Data to create inventory:");

    my $ref = $self->req->json;
    $self->app->log->debug( Dumper($ref) );
    
    if(exists $ref->{data}) {
      $ref = $ref->{data};
    }

    if ( exists $ref->{name} && exists $ref->{type} ) {
        $self->app->log->debug("Creating new inventory entry.");
        $ref->{c_date} = DateTime->now;
        $ref->{m_date} = DateTime->now;

        eval {
            my $properties = {};
            if ( exists $ref->{properties} ) {
                $properties = $ref->{properties};
                delete $ref->{properties};
            }

            my $hw = $self->db->resultset("Hardware")->create($ref);

            for my $key ( keys %{$properties} ) {
                $self->db->resultset("Property")->create(
                    {
                        name        => $key,
                        value       => $properties->{$key},
                        hardware_id => $hw->id,
                    }
                );
            }
            1;
        } or do {
            $self->app->log->error("Creating new inventory entry: $@");
            return $self->render(
                json => { ok => Mojo::JSON->false, error => $@ } );
        };
        return $self->render( json => { ok => Mojo::JSON->true } );
    }

    $self->render( json => { ok => Mojo::JSON->false }, status => 500 );
}

sub read {
    my $self = shift;

    my $hw_id = $self->param("hw_id");
    $self->app->log->debug("Want to read hw item: $hw_id");

    my $hw = $self->db->resultset("Hardware")->find($hw_id);

    if ( !$hw ) {
        return $self->render(
            json =>
              { ok => Mojo::JSON->true, message => "Hardware not found." },
            status => 404
        );
    }

    $self->render(
        json => { ok => Mojo::JSON->true, data => [ $hw->all_data ] } );
}

sub read_all {
    my $self = shift;

    my $rs = $self->db->resultset("Hardware")->search(
        {
          group_id => $self->param("group_id"),
        },
        {
            page => ( $self->param("page") || 1 ),
            rows => ( $self->param("rows") || 15 ),
        }
    );

    my @ret;
    while ( my $hw = $rs->next ) {
        push @ret, $hw->all_data;
    }

    $self->render( json => { ok => Mojo::JSON->true, data => \@ret } );
}

sub remove {
    my $self = shift;

    my $hw_id = $self->param("hw_id");
    $self->app->log->debug("Want to delete hw item: $hw_id");

    my $hw = $self->db->resultset("Hardware")->find($hw_id);

    if ( !$hw ) {
        return $self->render(
            json =>
              { ok => Mojo::JSON->true, message => "Hardware not found." },
            status => 404
        );
    }

    $hw->delete;

    $self->render( json => { ok => Mojo::JSON->true } );
}

sub update {
    my $self = shift;

    my $hw_id = $self->param("hw_id");
    $self->app->log->debug("Want to update hw item: $hw_id");

    my $hw = $self->db->resultset("Hardware")->find($hw_id);

    if ( !$hw ) {
        return $self->render(
            json =>
              { ok => Mojo::JSON->true, message => "Hardware not found." },
            status => 404
        );
    }

    my $ref = $self->req->json;

    eval {
        my $properties = {};
        if ( exists $ref->{properties} ) {
            $properties = $ref->{properties};
            delete $ref->{properties};
        }

        $hw->update($ref) if ( scalar keys %{$ref} > 0 );

        if ( scalar keys %{$properties} ) {
            for my $prop ( $hw->properties ) {
                $prop->delete;
            }

            for my $key ( keys %{$properties} ) {

                $self->db->resultset("Property")->create(
                    {
                        name        => $key,
                        value       => $properties->{$key},
                        hardware_id => $hw->id,
                    }
                );
            }
        }
        1;
    } or do {
        $self->app->log->error("Updating inventory entry: $@");
        return $self->render(
            json => { ok => Mojo::JSON->false, error => $@ } );
    };
    return $self->render( json => { ok => Mojo::JSON->true } );
}

1;
