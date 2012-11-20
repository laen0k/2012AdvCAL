package wxGrid;

use base 'Wx::Grid';
use Encode qw/encode decode/;
use Wx::Event qw/EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_RIGHT_CLICK/;;

sub new{
    my ($class, $frame, @arg_list)  = @_;
    my $self = $class->SUPER::new( $frame, -1);
    $self->_init(@arg_list);
    return $self;
}

sub _init{
    my ($self, $rows, $cols, $cells) = @_;

    $self->CreateGrid( scalar @{$rows}, scalar @{$cols} );
    $self->draw_grid( $rows, $cols, $cells );
    $self->SetRowLabelSize(150);
}

sub evt_click{
    my ($self, $func) = @_;

    EVT_GRID_LABEL_RIGHT_CLICK( $self, $func->(0) );
    EVT_GRID_LABEL_LEFT_CLICK( $self, $func->(1) );
}

sub draw_grid{
    my ( $self, $rows, $cols, $cells ) = @_;

    $self->SetRowLabelValue( $_, _utf2cp949($rows->[$_]) ) foreach ( 0 .. $#{$rows} );
    $self->SetColLabelValue( $_, _utf2cp949($cols->[$_]) ) foreach ( 0 .. $#{$cols} );
    $self->SetCellValue( $_ / @{$cols}, $_ % @{$cols}, _utf2cp949($cells->[$_]) ) foreach ( 0 .. $#{$cells} );
}

sub _utf2cp949 { encode('cp949', decode('utf8', shift )) } 

1;
