package Json;

use strict;
use warnings;

sub new{
    my ($class) = @_;
    my $self = {};
    bless($self, $class);
    return $self;
}
sub load_file{
    my ($self, $file) = @_;
    my $text = "";
    open(my $fh, "<", $file);
    while(<$fh>){
	$text .= $_;
    }
    close($fh);
    $self->{"text"} = $text;
    return;
}
sub load_text{
    my ($self, $text) = @_;
    $self->{"text"} = $text;
    return;
}
sub pretty_json{
    my ($self, $indent) = @_;
    $indent = " "x2 unless(defined($indent));
    my $count = 0;
    my $result = "";
    my $text = $self->{"text"};
    open(my $fh, "<", \$text);
    my $flag = 0;
    while(1){
	my $one_char = getc($fh);
	if($one_char eq "\n"){
	    $flag = 1;
	}elsif($flag){
	    if($one_char eq "\t" or $one_char eq " " or $one_char eq "\n"){
		
	    }else{
		$flag = 0;
	    }
	}
	if($flag){
	}else{
	    if($one_char eq "{" or $one_char eq "["){
		$result .= "\n";
		$result .= $indent x $count;
		$result .= $one_char;
		$result .= "\n";
		$count ++;
		$result .= $indent x $count;

	    }elsif($one_char eq "}" or $one_char eq "]"){
		$result .= "\n";
		$count --;
		$result .= $indent x $count;
		$result .= $one_char;

	    }elsif($one_char eq ","){
		$result .= $one_char;
		$result .= "\n";
		$result .= $indent x $count;

	    }else{
		$result .= $one_char;
	    }
	}
	if(eof($fh)){
	    last;
	}
    }
    close($fh);
    $result =~ s/^\s+//;
    return $result;
}
sub parse{
    my ($self) = @_;
    my @token_list = tokenizer($self);
    my $tokens_ref = \@token_list;
    my $index = 0;
    my $index_ref = \$index;
    my $init_node = proc($self, $tokens_ref, $index_ref, 0);
    return $init_node;
}
sub proc{
    my ($self, $tokens_ref, $index_ref, $indent) = @_;
    my $one_token = $tokens_ref->[$$index_ref];
    my $node;
    # 더 이상 읽어들일 것이 없으면 중지한다.
    return unless(defined($one_token));

    if($one_token eq "{"){
	$node = proc_brace($self, $tokens_ref, $index_ref, $indent);
    }elsif($one_token eq "["){
	$node = proc_bracket($self, $tokens_ref, $index_ref, $indent);
    }else{
	$node = proc_normal($self, $tokens_ref, $index_ref, $indent);
    }
    return $node;
}
sub proc_brace{
    my ($self, $tokens_ref, $index_ref, $indent) = @_;
    my $start_index = $$index_ref;

    my $node = Node->new;
    $node->type("object");

    if($tokens_ref->[$$index_ref +1] eq "}"){
	# 빈 object {} 의 경우이다.
	# 바로 리턴하여 object 구성을 종료시킨다.
	$$index_ref ++;
	$$index_ref ++;
	return $node;
    }
    
    while(1){
	$$index_ref ++;
	# 토큰 3개를 차례로 name, :, value 로 간주하여 처리한다.
	# 단 value 는 다시 object 나 array 가 될수 있으므로 proc 을 다시 호출하여 node 로 만든다.
	my $name = $tokens_ref->[$$index_ref];
	$$index_ref ++; # 콜론 자리
	$$index_ref ++; # value 시작
	my $value_node = proc($self, $tokens_ref, $index_ref, $indent +1);
	$value_node->indent($indent +1);
	$node->object_set($name, $value_node);
	
	# 그 다음 토큰을 체크한다. "," 이면 한 번 더 돌고 "}" 이면 종료시킨다.
	if($tokens_ref->[$$index_ref] eq ","){
	    # 흘려 보내서 while 을 다시 타게 한다.
	}elsif($tokens_ref->[$$index_ref] eq "}"){
	    # 이번 object 구성을 종료시킨다.
	    $$index_ref ++;
	    last;
	}else{
	    die "Type Brace: Can not possible [".$tokens_ref->[$$index_ref]."]\n";
	}
    }
    my $end_index = $$index_ref -1;
    my $content = "";
    foreach ($start_index..$end_index){
	$content .= $tokens_ref->[$_];
    }
    $node->content($content);
    $node->indent($indent);
    return $node;
}
sub proc_bracket{
    my ($self, $tokens_ref, $index_ref, $indent) = @_;
    my $start_index = $$index_ref;

    my $node = Node->new;
    $node->type("array");

    if($tokens_ref->[$$index_ref +1] eq "]"){
	# 빈 array [] 의 경우이다.
	# 바로 리턴하여 array 구성을 종료시킨다.
	$$index_ref ++;
	$$index_ref ++;
	return $node;
    }
    
    while(1){
	$$index_ref ++;
	# value node 를 생성한다.
	my $value_node = proc($self, $tokens_ref, $index_ref, $indent +1);
	$value_node->indent($indent +1);
	$node->array_add($value_node);

	# 그 다음 토큰을 체크한다. "," 이면 한 번 더 돌고 "]" 이면 종료한다.
	if($tokens_ref->[$$index_ref] eq ","){
	    # 다시 while 문을 돈다.
	}elsif($tokens_ref->[$$index_ref] eq "]"){
	    # array 구성을 종료시킨다.
	    $$index_ref ++;
	    last;
	}else{
	    die "Type Bracket: Can not possible [".$tokens_ref->[$$index_ref]."]\n";
	}
    }

    my $end_index = $$index_ref -1;
    my $content = "";
    foreach ($start_index..$end_index){
	$content .= $tokens_ref->[$_] if(defined($tokens_ref->[$_]));
    }
    $node->content($content);
    $node->indent($indent);
    return $node;
}
sub proc_normal{
    my ($self, $tokens_ref, $index_ref, $indent) = @_;
    my $candidate = $tokens_ref->[$$index_ref];
    # 노드를 하나 만든다.
    my $node = Node->new;
    # 이건 normal 타입이다.
    $node->type("normal");
    # 토큰을 값으로 세팅한다
    $node->normal_set($candidate);
    $node->content($candidate);
    $$index_ref ++;
    $node->indent($indent);
    return $node;
}

sub tokenizer{
    my ($self) = @_;
    my $json_text = $self->{"text"};
    my @reserved = ("{", "}", "[", "]", ":", ",");
    my %reserved_map = map { $_=>1 } @reserved;
    my @tokens = ();
    my @accumulated = ();
    my $total_length = length($json_text);
    my $idx = 0;
    my $string_flag = 0;
    my $before;
    my $before_before;
    while($idx < $total_length){
    	my $current = substr($json_text, $idx, 1);
    	# 따옴표를 만났는데
    	if($current eq "\""){
    	    # 이미 문자열 상태였다고 하자.
    	    if($string_flag){
		# 그런데 전전 문자가 역슬래시가 아니고, 직전 문자가 역슬래시 였다면 계속 문자열 상태이다.
		if($before eq "\\" and $before_before ne "\\"){
		    push(@accumulated, $current);
		}else{
		    # 그렇지 않다면 따옴표를 토큰으로 만들어 추가한다.
		    push(@accumulated, $current);
		    # 시작과 끝 " 를 제거한다.
		    shift(@accumulated);
		    pop(@accumulated);
		    # 누적 값을 토큰 리스트에 추가하고 초기화한다.
		    push(@tokens, join("", @accumulated));
		    @accumulated = ();
		    # 문자열 상태를 해제한다.
		    $string_flag = 0;
		}
    	    }else{
		# 문자열 상황이 아니었다면 문자열 상태로 전환한다.
		push(@accumulated, $current);
		$string_flag = 1;
    	    }
    	}else{
    	    # 문자열 상태일 때 따옴표가 아닌 문자는 예약어 여부에 관계없이 문자열로 처리한다.
    	    if($string_flag){
		push(@accumulated, $current);
    	    }else{
		# 문자열 상태가 아닌 상황에서 예약어를 만났다.
		if(defined($reserved_map{$current})){
		    # 이전에 누적한 값이 있다면
		    if(scalar(@accumulated)>0){
			# 토큰 리스트에 기존에 쌓았던 값을 붙여 토큰을 만들어 추가한다.
			push(@tokens, join ("", @accumulated));
		    }
		    # 예약어 자체도 토큰으로 만들어 추가하고 누적값을 초기화한다.
		    push(@tokens, $current);
		    @accumulated = ();
		}elsif($current =~ m/\s/){
		    # 문자열 상태가 아니면 공백은 무시한다.
		}else{
		    # 예약어가 아니라면 누적된 값에 추가해 놓는다.
		    push(@accumulated, $current);
		}
    	    }
    	}
    	$idx ++;
	$before_before = $before;
    	$before = $current;
    }
    return @tokens;
}

{
    package Node;
    sub new{
	my ($class) = @_;
	my $self = {};
	$self->{"type"} = undef;
	$self->{"object"} = {};
	$self->{"array"} = [];
	$self->{"normal"} = undef;
	$self->{"indent"} = 0;
	$self->{"content"} = undef;

	bless($self, $class);
	return $self;
    }
    sub value{
	my ($self) = @_;
	return normal_get($self);
    }
    sub get{
	my ($self, $key) = @_;
	if(defined($key)){
	    return object_get($self, $key);
	}else{
	    return normal_get($self);
	}
    }
    sub gets{
	my ($self) = @_;
	return array_gets($self);
    }
    sub type{
	my ($self, $neo) = @_;
	$self->{"type"} = $neo if(defined($neo));
	return $self->{"type"};
    }
    sub object_get{
	my ($self, $key) = @_;
	return $self->{"object"}->{$key};
    }
    sub object_set{
	my ($self, $key, $value) = @_;
	$self->{"object"}->{$key} = $value;
	return;
    }
    sub object_keys{
	my ($self) = @_;
	return keys %{$self->{"object"}};
    }
    sub array_gets{
	my ($self) = @_;
	return @{$self->{"array"}};
    }
    sub array_add{
	my ($self, $value) = @_;
	push(@{$self->{"array"}}, $value);
	return;
    }
    sub normal_get{
	my ($self) = @_;
	return $self->{"normal"};
    }
    sub normal_set{
	my ($self, $neo) = @_;
	$self->{"normal"} = $neo;
	return;
    }
    sub content{
	my ($self, $neo) = @_;
	$self->{"content"} = $neo if(defined($neo));
	return $self->{"content"};
    }
    
    sub indent{
	my ($self, $neo) = @_;
	$self->{"indent"} = $neo if(defined($neo));
	return $self->{"indent"};
    }
    sub info{
	my ($self, $unit_indent) = @_;
	$unit_indent = "  " unless(defined($unit_indent));
	my $result = "";
	if($self->type eq "object"){
	    foreach ($self->object_keys){
		$result .= sprintf "%sobj_key: %s\n", $unit_indent x $self->indent, $_;
		$result .= info($self->object_get($_), $unit_indent);
	    }
	}elsif($self->type eq "array"){
	    $result .= sprintf "%s[\n", $unit_indent x $self->indent;
	    foreach ($self->array_gets){
		$result .= info($_, $unit_indent);
	    }
	    $result .= sprintf "%s]\n", $unit_indent x $self->indent;
	}elsif($self->type eq "normal"){
	    $result .= sprintf "%svalue: %s\n", $unit_indent x $self->indent, $self->value;
	}
	return $result;
    }
}

return "Json";
