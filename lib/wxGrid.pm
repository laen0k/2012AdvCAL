package wxGrid;

use base 'Wx::Grid';
use Wx::Event qw/EVT_GRID_LABEL_LEFT_CLICK EVT_GRID_LABEL_RIGHT_CLICK/;;
use wxPerl::Styles 'wxVal';

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
    $self->AutoSizeColumns(1);
    $self->SetDefaultCellAlignment(wxVal('align_right'), wxVal('align_centre'));
}

sub evt_click{
    my ($self, $func) = @_;

    EVT_GRID_LABEL_RIGHT_CLICK( $self, $func->(0) );
    EVT_GRID_LABEL_LEFT_CLICK( $self, $func->(1) );
}

sub draw_grid{
    my ( $self, $rows, $cols, $cells ) = @_;

    $self->SetRowLabelValue( $_, $rows->[$_] ) foreach 0 .. $#{$rows};
    $self->SetColLabelValue( $_, $cols->[$_] ) foreach 0 .. $#{$cols};
    $self->SetCellValue( $_ / @{$cols}, $_ % @{$cols}, $cells->[$_] ) foreach 0 .. $#{$cells};
}

1;
