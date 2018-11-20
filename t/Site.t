#!perl
use strict;
use warnings;
use Test::More;
use lib 'lib';
use Mojo::UserAgent;
use Mojolicious::Lite;

use_ok 'Site';

get '/basic' => sub {
    my $c     = shift;
    my $delay = $c->req->query_params->param('delay') // 0.200;
    my $code  = $c->req->query_params->param('code') // 200;

    $c->render_later;

    Mojo::IOLoop->timer(
        $delay => sub {
            $c->render(template => 'html-timer', delay => $delay, status => $code);
        }
    );
};

## 404
my $site = Site->new(name => 'Not Found', url => '/not-found', ua => Mojo::UserAgent->new);
$site->check->wait;
ok $site->is_up, 'site is up';
ok !$site->is_ok, 'site is not ok';
is $site->response->code, 404, 'page not found';

## error: inactivity timeout
$site
  = Site->new(name => 'timeout error 1', url => '/basic?delay=1', inactivity_timeout => 0.100, ua => Mojo::UserAgent->new);
$site->check->wait;
cmp_ok $site->latency, '>=', 0.100, 'timeout';
ok !$site->is_up, 'site is not up';
ok !$site->is_ok, 'site is not ok';
like $site->error, qr/inactivity timeout/i, 'inactivity timeout';

## error: request timeout
$site
  = Site->new(name => 'timeout error 2', url => '/basic?delay=1', request_timeout => 0.100, ua => Mojo::UserAgent->new);
$site->check->wait;
cmp_ok $site->latency, '>=', 0.100, 'timeout';
ok !$site->is_up, 'site is not up';
ok !$site->is_ok, 'site is not ok';
like $site->error, qr/request timeout/i, 'request timeout';

## match
$site = Site->new(name => 'content match', url => '/basic?delay=0', method => 'get', ua => Mojo::UserAgent->new);
$site->check->wait;
ok $site->is_up, 'site is up';
ok $site->is_ok, 'site is ok';
is $site->response->dom->at('head title')->text, 'Welcome', 'site content match';

## 200: happy case
$site = Site->new(name => 'happy 1', url => '/basic?delay=0', ua => Mojo::UserAgent->new);
$site->check->wait;
ok $site->is_up, 'site is up';
ok $site->is_ok, 'site is ok';

## 204: unexpected
$site = Site->new(name => 'wrong code', url => '/basic?delay=0&code=204', ua => Mojo::UserAgent->new);
$site->check->wait;
ok $site->is_up, 'site is up';
ok !$site->is_ok, 'site is not ok' or diag "code: " . $site->response->code;

## 204: happy case
$site
  = Site->new(name => 'right code', url => '/basic?delay=0&code=204', status_code => 204, ua => Mojo::UserAgent->new);
$site->check->wait;
ok $site->is_up, 'site is up';
ok $site->is_ok, 'site is ok';

done_testing();

__DATA__

@@ html-timer.html.ep
% layout 'default';
% title 'Welcome';
<h1>The website is working</h1>
<p>Delay of <%= $delay %></p>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
