#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Controller::Property;

use Mojo::Base 'Mojolicious::Controller';
use DateTime;

sub create {
  my $self = shift;

  my $hw_id = $self->param("hw_id");
  $self->app->log->debug("Want to create hw property for: $hw_id");

  my $hw_o = $self->db->resultset("Hardware")->find($hw_id);

  if ( !$hw_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Hardware not found." },
      status => 404
    );
  }

  my $ref = $self->req->json;
  $ref->{c_date} = DateTime->now;
  $ref->{m_date} = DateTime->now;

  if ( exists $ref->{name} && exists $ref->{value} ) {
    eval {
      $self->db->resultset("Property")->create(
        {
          hardware_id => $hw_id,
          %{$ref},
        }
      );
      1;
    } or do {
      $self->app->log->error("Creating new property entry: $@");
      return $self->render( json => { ok => Mojo::JSON->false, error => $@ } );
    };
    
    return $self->render( json => { ok => Mojo::JSON->true } );
  }
  
  $self->render( json => { ok => Mojo::JSON->false, }, status => 400 );
}

sub read {
  my $self = shift;

  my $hw_id   = $self->param("hw_id");
  my $prop_id = $self->param("prop_id");

  $self->app->log->debug("Want to read hw property for: $hw_id -> $prop_id");

  my $hw_o = $self->db->resultset("Hardware")->find($hw_id);
  if ( !$hw_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Hardware not found." },
      status => 404
    );
  }

  my $prop_o = $self->db->resultset("Property")->find($prop_id);
  if ( !$prop_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Property not found." },
      status => 404
    );
  }

  $self->render(
    json => { ok => Mojo::JSON->true, data => $prop_o->add_data } );
}

sub remove {
  my $self = shift;

  my $hw_id   = $self->param("hw_id");
  my $prop_id = $self->param("prop_id");

  $self->app->log->debug("Want to delete hw property for: $hw_id -> $prop_id");

  my $hw_o = $self->db->resultset("Hardware")->find($hw_id);
  if ( !$hw_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Hardware not found." },
      status => 404
    );
  }

  my $prop_o = $self->db->resultset("Property")->find($prop_id);
  if ( !$prop_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Property not found." },
      status => 404
    );
  }

  $prop_o->delete;

  $self->render( json => { ok => Mojo::JSON->true, } );
}

sub update {
  my $self = shift;

  my $hw_id   = $self->param("hw_id");
  my $prop_id = $self->param("prop_id");

  $self->app->log->debug("Want to update hw property for: $hw_id -> $prop_id");

  my $hw_o = $self->db->resultset("Hardware")->find($hw_id);
  if ( !$hw_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Hardware not found." },
      status => 404
    );
  }

  my $prop_o = $self->db->resultset("Property")->find($prop_id);
  if ( !$prop_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Property not found." },
      status => 404
    );
  }

  my $ref = $self->req->json;
  $prop_o->update($ref);

  $self->render( json => { ok => Mojo::JSON->true, } );
}

1;
