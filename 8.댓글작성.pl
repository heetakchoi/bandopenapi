#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";
use Https;
use Prop;
use Json;

my $prop = Prop->new("info.txt", " ");

my ($access_token, $band_key, $post_key) = $prop->gets("access_token", "band_key", "post_key");
my $body = "Comment! friends.";

my $https = Https->new;
$https->host("openapi.band.us")
    ->url("/v2/band/post/comment/create")
    ->param("access_token", $access_token)
    ->param("band_key", $band_key)
    ->param("post_key", $post_key)
    ->param("body", $body)
    ;

my $result = $https->post();
my $json = Json->new;
$json->load_text($result);
print $json->pretty_json;
print "\n";
