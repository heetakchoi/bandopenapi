#!/usr/bin/perl

use strict;
use warnings;

use lib "lib";
use Https;
use Prop;
use Json;

print "\n", "#"x80, "\n";

print "[TEST CASE 1]\n";
my $prop = Prop->new("info.txt", " ");
my ($access_token) = $prop->gets("access_token");
printf "환경파일 읽기에 성공했습니다.\naccess token은 %s입니다.\n", $access_token;

print "\n", "#"x80, "\n";

print "[TEST CASE 2]\n";
my $https = Https->new;
$https->host("naver.com")
    ->url("/")
    ;
my $result = $https->get();
printf "naver.com에 요청을 보냅니다.\n%s", $result;
print "\n", "#"x80, "\n";
