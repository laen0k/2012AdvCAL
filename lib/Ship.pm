package Ship;

use LWP::UserAgent;
use HTML::TreeBuilder;
use Data::Dumper;

sub new{
    my $class = shift;
    my $self = bless {}, $class;
    $self->_init;
    return $self;
}

sub _init{
    my $self = shift;

    $self->{'attrorder'} = ["함선 종류", "모험 레벨", "교역 레벨", "전투 레벨"];
    my @ship_kind = qw/탐험용 상업용 전투용 ※캐쉬/;
    my %ship_html;

    foreach (0 .. $#ship_kind){
	my $browser = LWP::UserAgent->new;
	my $tree = HTML::TreeBuilder->new;
	my $num = $_ + 1;

	$num = 9 if ($_ == 3);
	$ship_html{$ship_kind[$_]} = 
	    $tree->parse($browser->get("http://uwodbmirror.ivyro.net/kr/main.php?id=145&chp=" . $num)->content);
    }

    foreach my $ship_kind (@ship_kind){
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
