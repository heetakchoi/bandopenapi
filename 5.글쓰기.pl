#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";
use Https;
use Prop;
use Json;

my $prop = Prop->new("info.txt", " ");

my ($access_token, $band_key, $content) = $prop->gets("access_token", "band_key", "content");
$content = "BAND write TEST [%]" unless(defined($content));

my $https = Https->new;
$https->host("openapi.band.us")
    ->url("/v2.2/band/post/create")
    ->param("access_token", $access_token)
    ->param("band_key", $band_key)
    ->param("content", $content)
    ;
my $result = $https->post();
my $json = Json->new;
$json->load_text($result);
print $json->pretty_json;
print "\n";

# print $https->info;
