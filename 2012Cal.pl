#!/usr/bin/perl

use strict;
use warnings;
use Wx;

use lib 'lib';
use wxGrid;
use Ship;
use Data::Dumper;
use utf8;

my $app = Wx::SimpleApp->new;
my $frame = Wx::Frame->new( undef, -1, 'Wx Grid', [-1, -1], [438, 800] );
my $ship = Ship->new;

my $grid = wxGrid->new($frame, $ship->grid_list->{'함선명'}, $ship->attrorder, $ship->grid_list->{'함선정보'});

$grid->evt_click($ship->sort_grid);

$frame->Show;
$app->MainLoop;


