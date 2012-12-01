package Ship;

use LWP::UserAgent;
use HTML::TreeBuilder;
use Encode qw/decode/;
use utf8;

sub new{
    my $class = shift;
    my $self = bless {}, $class;
    $self->_init;
    return $self;
}

sub _init{
    my $self = shift;

    $self->{'attrorder'} = ["함선 종류", "모험 레벨", "교역 레벨", "전투 레벨"];
    my %ship_kind = ( "탐험용" => 1, "상업용" => 2, "전투용" => 3, "※캐쉬" => 9 );
    my %ship_html;
    my $ua = LWP::UserAgent->new;

    my ($rsp, $html, $tree);
    foreach (keys %ship_kind){
	$rsp = $ua->get("http://uwodbmirror.ivyro.net/kr/main.php?id=145&chp=" . $ship_kind{$_});
	$html = decode('utf8', $rsp->content);

	$tree = HTML::TreeBuilder->new;
	$ship_html{$_} = $tree->parse($html);
    }

    foreach my $ship_kind (keys %ship_kind){
	my $ship_name;
	foreach ($ship_html{$ship_kind}->look_down(
		     sub { $_[0]->attr('href') =~ /main\.php\?id=5\d{7}/ or $_[0]->attr('class') =~ /level\d/ }
		 )){
	    if ($_->attr_get_i('href')){
		$ship_name = $_->as_text;
		$self->{'ship'}{$ship_name}{'함선 종류'} = $ship_kind;
	    } else {
		$self->{'ship'}{$ship_name}{$_->attr_get_i('title')} = $_->as_text;
	    }

	}
    }
}

sub info { shift->{'ship'} }
sub attrorder { shift->{'attrorder'} }
sub count{ scalar( keys %{shift->{'ship'}} ) }

sub grid_list{
    my ($self, $getCol, $order) = @_;
    my $ship_grid;

    foreach my $ship_name ( sort { $self->_sort($getCol, $order) } keys %{$self->info} ){
	push @{$ship_grid->{'함선명'}}, $ship_name;
	foreach ( @{$self->attrorder} ){
	    push @{$ship_grid->{'함선정보'}}, $self->info->{$ship_name}{$_};
	}
    }

    return $ship_grid;
}    

sub sort_grid{
    my $self = shift;

    return sub {
	my $order = shift;

	return sub{
	my ($grid, $event) = @_;
	my $sort;
	
	$sort = $self->grid_list ( $event->GetCol, $order );

	$grid->draw_grid($sort->{'함선명'}, $self->attrorder, $sort->{'함선정보'});
	}
    }
}

sub _sort{
    my ($self, $getCol, $order) = @_;
    my @ship_cols = @{$self->attrorder};

	unless ( $getCol ){
	    ($order)?
		return $self->info->{$a}{$ship_cols[$getCol]} cmp $self->info->{$b}{$ship_cols[$getCol]} || $a cmp $b:
		return $self->info->{$b}{$ship_cols[$getCol]} cmp $self->info->{$a}{$ship_cols[$getCol]} || $a cmp $b;		
	} else {
	    ($order)?
		return $self->info->{$b}{$ship_cols[$getCol]} <=> $self->info->{$a}{$ship_cols[$getCol]} || $a cmp $b:
		return $self->info->{$a}{$ship_cols[$getCol]} <=> $self->info->{$b}{$ship_cols[$getCol]} || $a cmp $b;
	}
}

1;
