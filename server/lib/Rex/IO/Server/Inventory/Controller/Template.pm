#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::Server::Inventory::Controller::Template;

use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub read {
  my $self = shift;

  my $template_id = $self->param("template_id");

  $self->app->log->debug("Want to read template: $template_id");

  my $template_o = $self->db->resultset("Template")->find($template_id);
  if ( !$template_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->true, message => "Template not found." },
      status => 404
    );
  }

  $self->render(
    json => { ok => Mojo::JSON->true, data => $template_o->all_data } );
}

sub create {
  my ($self) = @_;
  my $ref = $self->req->json;

  $self->app->log->debug("Try to create new template.");
  $self->app->log->debug("Got template data:");
  $self->app->log->debug( Dumper($ref) );

  if ( !exists $ref->{parent_id} ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Missing parent_id", },
      status => 500
    );
  }

  my $parent_o = $self->db->resultset("Template")->find( $ref->{parent_id} );

  if ( !$parent_o ) {
    return $self->render(
      json   => { ok => Mojo::JSON->false, error => "Parent not found.", },
      status => 404
    );
  }

  delete $ref->{parent_id};

  eval {
    $parent_o->add_to_children($ref);
    1;
  } or do {
    return $self->render( json => { ok => Mojo::JSON->false, error => $@ },
      500 );
  };

  $self->render( json => { ok => Mojo::JSON->true } );
}

sub remove {
  my ($self) = @_;

  $self->app->log->debug( "Try to delete template: " . $self->param("template_id") );

  my $template = $self->db->resultset("Template")->find($self->param("template_id"));

  if ($template) {
    $template->delete;
    return $self->render( json => { ok => Mojo::JSON->true } );
  }

  return $self->render( json => { ok => Mojo::JSON->false }, status => 404 );
}

sub update { }

1;
