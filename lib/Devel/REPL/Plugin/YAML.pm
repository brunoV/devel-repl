package Devel::REPL::Plugin::YAML;

use Devel::REPL::Plugin;
use YAML::XS qw(Dump);
use namespace::clean -except => 'meta';

around format_result => sub {
  my $orig = shift;
  my $self = shift;
  my $to_dump = (@_ > 1) ? [@_] : $_[0];
  my $out;
  if (ref $to_dump) {
    # TODO: fix coderefs
    $out = Dump($to_dump);
  } else {
    $out = $to_dump;
  }
  $self->$orig($out);
};

1;

__END__

=head1 NAME

Devel::REPL::Plugin::YAML - Format results with YAML::XS

=cut

