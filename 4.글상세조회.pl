#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";
use Https;
use Json;
use Prop;

my $prop = Prop->new("info.txt", " ");

my ($access_token, $band_key, $post_key) = $prop->gets("access_token", "band_key", "post_key");

my $https = Https->new;
$https->host("openapi.band.us")
    ->url("/v2.1/band/post")
    ->param("access_token", $access_token)
    ->param("band_key", $band_key)
    ->param("post_key", $post_key)
    ;
my $json = Json->new;
$json->load_text($https->get);
print $json->pretty_json;
print "\n";
