#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Rex::IO::WebUI::Inventory::Mojolicious::Plugin::RexIOServer;

use strict;
use warnings;

use Rex::IO::Client;
use Mojolicious::Plugin;
use base qw(Mojolicious::Plugin);

use Data::Dumper;

sub register {
  my ( $plugin, $app ) = @_;

  $app->helper(
    rexio => sub {
      my $self = shift;
      my $cl;

      if ( $app->config->{ssl} ) {
        $cl = Rex::IO::Client->create(
          protocol => 1,
          ssl      => $app->config->{server}->{ssl},
          endpoint => "https://"
            . $self->req->headers->header('X-RexIO-User') . ":"
            . $self->req->headers->header('X-RexIO-Password') . '@'
            . $self->req->headers->header('X-RexIO-Server'),
        );
      }
      else {
        $cl = Rex::IO::Client->create(
          protocol => 1,
          endpoint => "http://"
            . $self->req->headers->header('X-RexIO-User') . ":"
            . $self->req->headers->header('X-RexIO-Password') . '@'
            . $self->req->headers->header('X-RexIO-Server'),
        );
      }

      return $cl;
    }
  );
}

1;
