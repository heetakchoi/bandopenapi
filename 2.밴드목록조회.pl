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
my $init_node = $json->parse;
my @band_node_list = $init_node->get("result_data")->get("bands")->gets();
print "#"x80, "\n";
foreach my $band_node ( (@band_node_list) ){
    foreach ( ("name", "cover", "member_count", "band_key") ){
	printf ".  % 20s: %s\n", $_, $band_node->get($_)->value;
    }
    print "-"x80, "\n";
}
print "#"x80, "\n";
print $json->pretty_json;
print "\n";
print "#"x80, "\n";
