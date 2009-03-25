package Devel::REPL::Plugin::Term::ReadLine;
use Devel::REPL::Plugin;

has 'term' => (
  is => 'rw', required => 1,
  default => sub { Term::ReadLine->new('Perl REPL') }
);

has 'prompt' => (
  is => 'rw', required => 1,
  default => sub { '$ ' }
);

has 'out_fh' => (
  is => 'rw', required => 1, lazy => 1,
  default => sub { shift->term->OUT || \*STDOUT; }
);

around read => sub {
  my ($next, $self) = @_;
  return $self->term->readline($self->prompt);
};

around print => sub {
  my ($next, $self, @ret) = @_;
  my $fh = $self->out_fh;
  no warnings 'uninitialized';
  print $fh "@ret";
  print $fh "\n" if $self->term->ReadLine =~ /Gnu/;
};

1;
