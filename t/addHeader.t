#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 1;
use Test::Deep;
use Test::Exception;
use REST::Client;

my $client = REST::Client->new();
my $ua     = $client->getUseragent();

# snapshot client's default user agent headers
my %default;
$ua->default_headers->scan( sub { push @{ $default{ $_[0] } }, $_[1] } );

# add some headers
my %new = (
    'X-Foo' => 'hello',
    'X-Bar' => [qw(one two three)],
);
while ( my ( $field, $value ) = each %new ) {
    $client->addHeader( $field, $value );
}

# build expected default headers, convert scalars to arrayrefs to ease test
my %expected = ( %default, %new );
for ( grep { ref $expected{$_} ne q{} } keys %expected ) {
    $expected{$_} = [ $expected{$_} ];
}

# check the UA has everything we expect
cmp_deeply(
    $ua->default_headers,
    listmethods(
        map { [ header => $_ ] => $expected{$_} } keys %expected,
    ),
    'user agent default_headers updated by addHeader calls',
);
