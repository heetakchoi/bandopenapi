#!/usr/bin/perl

# 사용자 정보 조회
# https://developers.band.us/develop/guide/api/get_user_information

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
    ->url("/v2/profile")
    ->param("access_token", $access_token)
    ;
my $result = $https->get();
my $json = Json->new;
$json->load_text($result);
my $init_node = $json->parse;
print "#"x80, "\n";
foreach ( ("name", "profile_image_url", "user_key", "is_app_member", "message_allowed") ){
    printf ".  % 20s: %s\n", $_, $init_node->get("result_data")->get($_)->value;
}
print "#"x80, "\n";
print $json->pretty_json;
print "\n";
print "#"x80, "\n";
