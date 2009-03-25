package Devel::REPL::Plugin::Term::ReadLine;
use Devel::REPL::Plugin;

with 'Devel::REPL::Plugin::Term::Prompt';

has 'term' => (
  is => 'rw', required => 1,
  default => sub { Term::ReadLine->new('Perl REPL') }
);

has 'out_fh' => (
  is => 'rw', required => 1, lazy => 1,
  default => sub { shift->term->OUT || \*STDOUT; }
);

around read => sub {
  my ($next, $self) = @_;
  my $line = $self->term->readline($self->prompt);
  $self->done(1) if !defined $line;
  return $line;
};

around print => sub {
  my ($next, $self, @ret) = @_;
  my $fh = $self->out_fh;
  no warnings 'uninitialized';
  print $fh "@ret";
  print $fh "\n" if $self->term->ReadLine =~ /Gnu/;
};

1;
