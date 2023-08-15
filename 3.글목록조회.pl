#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";
use Https;
use Prop;
use Json;

my $prop = Prop->new("info.txt", " ");
my ($access_token, $band_key) = $prop->gets("access_token", "band_key");
my $locale = "ko_KR";

printf "access_token: %s\n", $access_token;
printf "band_key: %s\n", $band_key;
printf "locale: %s\n", $locale;

my $https = Https->new;
$https->host("openapi.band.us")
    ->url("/v2/band/posts")
    ->param("access_token", $access_token)
    ->param("band_key", $band_key)
    ->param("locale", $locale)
    ;
my $result = $https->post();
my $json = Json->new;
$json->load_text($result);
print $json->pretty_json;
print "\n";
