package Https;

use strict;
use warnings;

use IO::Socket::SSL;
use Mozilla::CA;
use URI::Encode qw(uri_encode uri_decode);

sub unchunk;
sub trim;

sub new{
    my ($class) = @_;
    my $self = {};
    $self->{"headers"} = {};
    $self->{"params"} = {};
    $self->{"ssl_verify_mode"} = SSL_VERIFY_PEER;
    bless($self, $class);
    return $self;
}
sub get{
    my ($self) = @_;
    my $host = $self->{"host"};
    my $port = $self->{"port"};
    $port = 443 unless(defined($port));
    my %param_map = %{ $self->{"params"}};
    my $req_uri = $self->{"url"};
    my $first_flag = 1;
    foreach my $param_key (keys %param_map){
	my $param_value = $param_map{$param_key};
	if($first_flag){
	    $req_uri .= "?";
	    $first_flag = 0;
	}else{
	    $req_uri .= "&";
	}
	$req_uri .= sprintf "%s=%s", uri_encode($param_key), uri_encode($param_value);
    }
    my $request_line = sprintf "GET %s HTTP/1.1\r\n", $req_uri;
    
    my %header_map = %{ $self->{"headers"}};
    unless(defined($header_map{"Host"})){
	if($port eq 80){
	    $header_map{"Host"} = sprintf("%s", $host);
	}else{
	    $header_map{"Host"} = sprintf("%s:%d", $host, $port);
	}
    }
    unless(defined($header_map{"Connection"})){
	$header_map{"Connection"} = "close";
    }
    my $request_head = "";
    foreach my $header_key (keys %header_map){
	my $header_value = $header_map{$header_key};
	$request_head .= sprintf "%s: %s\r\n", $header_key, $header_value;
    }
    my $raw_request = $request_line . $request_head . "\r\n";
    $self->{"raw_request"} = $raw_request;

    my $emulate_flag = $self->{"emulate_flag"};
    if($emulate_flag){
	return "";
    }else{    
	my $socket = IO::Socket::SSL->new(
	    PeerHost=>$host,
	    PeerPort=>$port,
	    SSL_verify_mode => $self->{"ssl_verify_mode"},
	    SSL_ca_file => Mozilla::CA::SSL_ca_file(),
	    ) or die "Can't connect: $@";
	$socket->verify_hostname($host, "http")
	    || die "hostname verification failure";

	print $socket $raw_request;

	my $raw_response = "";
	while(<$socket>){
	    $raw_response .= $_;
	}
	$self->{"raw_response"} = $raw_response;
	shutdown($socket, 2);
	$socket->close();

	my $neck_index = index($raw_response, "\r\n\r\n");
	my $response_head = substr($raw_response, 0, $neck_index);
	my $response_body = substr($raw_response, $neck_index + 4);
	my @response_headers = split(/\r\n/, $response_head);
	my $chunked_flag = 0;
	foreach my $response_header (@response_headers){
	    if($response_header =~ m/Transfer-Encoding/
	       && $response_header =~ m/chunked/){
		$chunked_flag = 1;
		last;
	    }
	}
	if($chunked_flag){
	    $response_body = unchunk($response_body);
	}
	return $response_body;
    }
}
sub post{
    my ($self) = @_;
    my $host = $self->{"host"};
    my $port = $self->{"port"};
    $port = 443 unless(defined($port));
    
    my $req_uri = $self->{"url"};
    my $request_line = sprintf "POST %s HTTP/1.1\r\n", $req_uri;
    
    my %header_map = %{ $self->{"headers"}};
    unless(defined($header_map{"Host"})){
	if($port eq 80){
	    $header_map{"Host"} = sprintf("%s", $host);
	}else{
	    $header_map{"Host"} = sprintf("%s:%d", $host, $port);
	}
    }
    unless(defined($header_map{"Connection"})){
	$header_map{"Connection"} = "close";
    }
    unless(defined($header_map{"Content-Type"})){
	$header_map{"Content-Type"} = "application/x-www-form-urlencoded";
    }

    my $request_body = "";
    my %param_map = %{ $self->{"params"}};
    my $first_flag = 1;
    foreach my $param_key (keys %param_map){
	my $param_value = $param_map{$param_key};
	$param_value = "" unless(defined($param_value));
	if($first_flag){
	    $first_flag = 0;
	}else{
	    $request_body .= "&";
	}
	$request_body .= sprintf "%s=%s", uri_encode($param_key), uri_encode($param_value);
    }
    my $payload = $self->{"payload"};
    if(defined($payload)){
	$request_body = $payload;
    }
    my $request_body_size = length($request_body);
    $header_map{"Content-Length"} = $request_body_size;

    my $request_head = "";
    foreach my $header_key (keys %header_map){
	my $header_value = $header_map{$header_key};
	$request_head .= sprintf "%s: %s\r\n", $header_key, $header_value;
    }
    my $raw_request = $request_line . $request_head . "\r\n" . $request_body;
    $self->{"raw_request"} = $raw_request;

    my $emulate_flag = $self->{"emulate_flag"};
    if($emulate_flag){
	return "";
    }else{    
	my $socket = IO::Socket::SSL->new(
	    PeerHost=> $host,
	    PeerPort=>$port,
	    SSL_verify_mode => $self->{"ssl_verify_mode"},
	    SSL_ca_file => Mozilla::CA::SSL_ca_file(),
	    ) or die "Can't connect: $@";
	$socket->verify_hostname($host, "http")
	    || die "hostname verification failure";

	print $socket $raw_request;

	my $raw_response = "";
	while(<$socket>){
	    $raw_response .= $_;
	}
	$self->{"raw_response"} = $raw_response;
	shutdown($socket, 2);
	$socket->close();

	my $neck_index = index($raw_response, "\r\n\r\n");
	my $response_head = substr($raw_response, 0, $neck_index);
	my $response_body = substr($raw_response, $neck_index + 4);
	my @response_headers = split(/\r\n/, $response_head);
	my $chunked_flag = 0;
	foreach my $response_header (@response_headers){
	    if($response_header =~ m/Transfer-Encoding/
	       && $response_header =~ m/chunked/){
		$chunked_flag = 1;
		last;
	    }
	}
	if($chunked_flag){
	    $response_body = unchunk($response_body);
	}
	return $response_body;
    }
}
sub unchunk{
    my ($chunked) = @_;
    my $unchunked = "";
    my $num_start_index = 0;

    while(1){
	my $num_end_index = index($chunked, "\r\n", $num_start_index +1);
	my $num_str = substr($chunked, $num_start_index, $num_end_index - $num_start_index);
	my $chunk_size_expected = hex(trim($num_str));
	if($chunk_size_expected == 0){
	    last;
	}
	$unchunked .= substr($chunked, $num_end_index+2, $chunk_size_expected);
	$num_start_index = $num_end_index + 2 + $chunk_size_expected + 2;
    }
    return $unchunked;
}

sub host{
    my ($self, $host) = @_;
    $self->{"host"} = $host;
    return $self;
}
sub port{
    my ($self, $port) = @_;
    $self->{"port"} = $port;
    return $self;
}
sub url{
    my ($self, $url) = @_;
    $self->{"url"} = $url;
    return $self;
}
sub header{
    my ($self, $key, $value) = @_;
    $self->{"headers"}->{$key} = $value;
    return $self;
}
sub param{
    my ($self, $key, $value) = @_;
    $self->{"params"}->{$key} = $value;
    return $self;
}
sub payload{
    my ($self, $payload) = @_;
    $self->{"payload"} = $payload;
    return $self;
}
sub ssl_verify_mode{
    my ($self, $ssl_verify_mode) = @_;
    $self->{"ssl_verify_mode"} = $ssl_verify_mode;
    return $self;
}
sub info{
    my ($self) = @_;
    return sprintf "===== REQ =====\n%s\n===== RES =====\n%s\n", $self->{"raw_request"}, $self->{"raw_response"};
}
sub emulate_flag{
    my ($self, $emulate_flag) = @_;
    $self->{"emulate_flag"} = $emulate_flag;
    return $self;
}
sub raw_request{
    my ($self) = @_;
    return $self->{"raw_request"};
}
sub trim{
    my ($str) = @_;
    $str =~ s/^(\s*)//;
    $str =~ s/(\s*)$//;
    return $str;
}
return "Https";
