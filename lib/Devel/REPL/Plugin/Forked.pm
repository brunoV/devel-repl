package Devel::REPL::Plugin::Forked;
use Devel::REPL::Plugin;

sub read_loop(&$;@) {
    my ($code, $handle, @type) = @_;

    @type = ('json') unless @type;

    my $handler; $handler = sub {
        my ($handle, @rest) = @_;
        $code->($handle, @rest);
        $handle->push_read( @type => $handler );
    };
    $handle->push_read( @type => $handler );
}

use namespace::clean except => '-meta';

use AnyEvent;
use AnyEvent::Subprocess;

has 'child' => (
    is         => 'ro',
    isa        => 'AnyEvent::Subprocess::Running',
    lazy_build => 1,
);

has 'in_evaluation' => (
    is       => 'ro',
    isa      => 'Bool',
    required => 1,
    default  => sub { 0 },
);

sub _build_child {
    my $self = shift;
    my @plugins = qw/LexEnv/;
    my $child = AnyEvent::Subprocess->new(
        code => sub {
            print "Hello from the child.\n";
            my ($handle) = @_;
            my $repl = Devel::REPL->new;
            $repl->load_plugin(@plugins);

            # my $handle = AnyEvent::Handle->new(
            #     fh => $fh,
            # );

            $repl->meta->add_method(done => sub {
                my ($self, $value) = @_;
                $handle->push_write(json => { type => 'done', value => '1' }) if $value;
                # otherwise, no-op
            });

            read_loop {
                my ($handle, $msg) = @_;
                my ($type, $value) = map { $msg->{$_} } qw/type value/;

                use Data::Dump::Streamer qw(Dump);
                print "Command from parent: ". Dump($msg);

                if($type eq 'eval'){
                    my $result = $repl->print($repl->formatted_eval($value));

                    $handle->push_write(json => {
                        type     => 'result',
                        value    => $result,
                        sequence => $msg->{sequence}, # keep client/server in sync
                    });
                }
            } $handle;
        },
    );

    # handle the events that the child generates (other than "result")

    $child = $child->run;

    read_loop {
        my ($handle, $msg) = @_;
        $self->done( $msg->{value} ) if $msg->{type} eq 'done';
    } $child->comm_handle;

    read_loop {
        my ($handle, $data) = @_;
        print $data;
    } $child->stdout_handle, chunk => 1;

    read_loop {
        my ($handle, $data) = @_;
        print {*STDERR} $data;
    } $child->stdout_handle, chunk => 1;

    return $child;
}

sub setup_terminal_handlers {
    my $self = shift;


    # also need to do STDIN; tricky because we have to "turn off" our
    # watcher when the user is at the command-line

}

sub eval_in_child {
    my ($self, $line) = @_;

    my $response_condvar = AnyEvent->condvar;
    my $sequence = rand; # so this eval only returns when "our" eval is done
    read_loop {
        my ($handle, $msg) = @_;
        if( $msg->{type} eq 'result' &&
              $msg->{sequence} == $sequence ){
            $response_condvar->send($msg->{value});
        }
    } $self->child->comm_handle;

    $self->child->comm_handle->push_write( json => {
        type     => 'eval',
        sequence => $sequence,
        value    => $line,
    });

    return $response_condvar;
}

sub eval {
    my ($self, $line) = @_;
    my $response = $self->eval_in_child($line);

    local $SIG{INT} = sub {
        $self->child->kill(9);
        $self->clear_child;
        $response->send('Killed');
    };

    return $response->wait;
}

1;
