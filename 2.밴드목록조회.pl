#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";
use Https;
use Prop;
use Json;

my $prop = Prop->new("info.txt", " ");
my ($access_token) = $prop->gets("access_token");

my $https = Https->new;
$https->host("openapi.band.us")
    ->url("/v2.1/bands")
    ->param("access_token", $access_token)
    ;
my $result = $https->get();
my $json = Json->new;
$json->load_text($result);
print $json->pretty_json;
print "\n";
