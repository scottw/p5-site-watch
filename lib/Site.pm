package Site;
use Moo;
use strictures 2;
use Types::Standard qw(Int Num Bool Str RegexpRef Object Enum);
use Site::Types qw(URL);
use Time::HiRes qw(gettimeofday tv_interval);

has connect_timeout    => (is => 'ro',  isa => Num);
has inactivity_timeout => (is => 'ro',  isa => Num);
has request_timeout    => (is => 'ro',  isa => Num);
has name               => (is => 'ro',  isa => Str, required => 1);
has url                => (is => 'ro',  isa => URL, required => 1);
has status_code        => (is => 'ro',  isa => Int, default => 200);
has redirects          => (is => 'ro',  isa => Int);                   ## 2 or 3?
has ua                 => (is => 'ro',  isa => Object);
has method             => (is => 'ro',  isa => Enum[qw(head get)], default => 'head');

has response           => (is => 'rwp', isa => Object);
has latency            => (is => 'rwp', isa => Num);
has error              => (is => 'rwp', isa => Str);
has is_up              => (is => 'rwp', isa => Bool);
has is_ok              => (is => 'rwp', isa => Bool);
has is_match           => (is => 'rwp', isa => Bool);

sub check {
    my $self = shift;

    ## we use milliseconds
    $self->ua->connect_timeout($self->connect_timeout)       if $self->connect_timeout;
    $self->ua->inactivity_timeout($self->inactivity_timeout) if $self->inactivity_timeout;
    $self->ua->request_timeout($self->request_timeout)       if $self->request_timeout;

    my $started = [gettimeofday()];

    my $method = $self->method . '_p';
    $self->ua->$method($self->url)->then(
        sub {
            my $tx = shift;
            $self->_set_latency(tv_interval($started, [gettimeofday()]));
            $self->_set_response($tx->res);
            $self->_set_is_up(1);
            $self->_set_is_ok($tx->res->code eq $self->status_code);
        }
    )->catch(
        sub {
            my $err = shift;
            $self->_set_latency(tv_interval($started, [gettimeofday()]));
            $self->_set_error($err);
            $self->_set_is_up(0);
            $self->_set_is_ok(0);
        }
    );
}

1;
