package Rex::IO::WebUI::Inventory::Controller::Templates;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub index {
  my $self = shift;
  $self->render("templates/index");
}

sub rows {
  my $self = shift;

#  my $entries =
#    $self->rexio->call( "GET", "1.0", "inventory", "inventory" => $self->param("group_id") )
#    ->{data};

#  my @ret;
#  for my $entry ( @{$entries} ) {
#    push @ret, [ $entry->{id}, $entry->{name}, $entry->{type} ];
#  }

  my @ret;
  push @ret, [ 1, "foo", "inventory/template/boot" ], [ 2, "bar", "inventory/template/install" ];

  $self->render( json => { ok => Mojo::JSON->true, data => \@ret } );
}

sub columns {
  my $self = shift;
  $self->render(
    json => {
      ok   => Mojo::JSON->true,
      data => [
        {
          width => 80,
          name  => "Id",
        },
        {
          name => "Name",
        },
        {
          width => 250,
          name  => "Type",
        },
      ],
    }
  );
}

sub types {
  my $self = shift;
  $self->render(
    json => {
      ok   => Mojo::JSON->true,
      data => [
        {
          id   => 'inventory/template/boot',
          name => 'Boot (PXE)',
        },
        {
          id   => 'inventory/template/install',
          name => 'Installation (Kickstart, ...)',
        },
      ]
    }
  );
}



1;
