#!/usr/bin/perl -w

# $Id: pixmaped-buttons.pl,v 1.22 1999/03/10 21:24:44 root Exp $

# (c) Mark Summerfield 1999. All s Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


my $RightMenu ;


# The button frame.
my $ButtonFrame = $Win->Frame()->pack( 
                -fill => 'y',
                -side => 'left',
                ) ;

# Left hand button column.
my $Frame = $ButtonFrame->Frame()->pack( 
                -fill => 'y',
                -side => 'left',
                ) ;


$Button{WIDGET}{PENCIL} = $Frame->Button(
    -image   => $Const{PENCIL_IMAGE},
    -command => [ \&button::set_button, 'PENCIL' ],
    )->pack() ;
$Button{WIDGET}{PENCIL}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{PENCIL}, 'Draw single pixels.' ] ) ;
$Button{WIDGET}{PENCIL}->bind( '<Leave>', \&button::enter ) ;


=pod
$Button{WIDGET}{FILL} = $Frame->Button(
    -image   => $Const{FILL_IMAGE},
    -command => [ \&button::set_button, 'FILL' ],
    )->pack() ;
$Button{WIDGET}{FILL}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{FILL}, 'Fill the area clicked.' ] ) ;
$Button{WIDGET}{FILL}->bind( '<Leave>', \&button::enter ) ;
=cut


# Rotation begin.
$Button{WIDGET}{ROTATE} = $Frame->Button(
    -image   => $Const{ROTATE_IMAGE},
    -command => [ \&button::set_button, 'ROTATE' ],
    )->pack() ;
$Button{WIDGET}{ROTATE}->bind( '<Enter>', \&show_rotation ) ;
$Button{WIDGET}{ROTATE}->bind( '<Leave>', \&button::enter ) ;

sub show_rotation {

    &button::enter( 
        $Button{WIDGET}{ROTATE},
        "Rotate the image $Opt{ROTATION} degrees. Right click to change angle." 
        ) ;
}

$RightMenu = $Win->Menu( 
                    -tearoff => 0,
                    -menuitems => [ 
                        [ 
                            Button   => '90 degree rotation',  
                            -command => sub { $Opt{ROTATION} = 90 }, 
                        ],
                        [ 
                            Button   => '180 degree rotation',  
                            -command => sub { $Opt{ROTATION} = 180 }, 
                        ],
                        [ 
                            Button   => '270 degree rotation',  
                            -command => sub { $Opt{ROTATION} = 270 }, 
                        ],
                    ],
                    ) ;
$Button{WIDGET}{ROTATE}->bind( '<3>', [ \&rotation_menu, $RightMenu ] ) ;

sub rotation_menu {

    my( $win, $menu ) = @_ ;

    my $event = $win->XEvent ;

    $menu->post( $event->X, $event->Y ) ; 
}
# Rotation end.


$Button{WIDGET}{FLIP_HORIZONTAL} = $Frame->Button(
    -image   => $Const{FLIP_HORIZONTAL_IMAGE},
    -command => [ \&button::set_button, 'FLIP_HORIZONTAL' ],
    )->pack() ;
$Button{WIDGET}{FLIP_HORIZONTAL}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{FLIP_HORIZONTAL}, 
      'Flip the image horizontally.' ] ) ;
$Button{WIDGET}{FLIP_HORIZONTAL}->bind( '<Leave>', \&button::enter ) ;


$Button{WIDGET}{OVAL} = $Frame->Button(
    -image   => $Const{OVAL_IMAGE},
    -command => [ \&button::set_button, 'OVAL' ],
    )->pack() ;
$Button{WIDGET}{OVAL}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{OVAL}, 'Draw an oval.' ] ) ;
$Button{WIDGET}{OVAL}->bind( '<Leave>', \&button::enter ) ;


=pod
$Button{WIDGET}{OVAL_FILLED} = $Frame->Button(
    -image   => $Const{OVAL_FILLED_IMAGE},
    -command => [ \&button::set_button, 'OVAL_FILLED' ],
    )->pack() ;
$Button{WIDGET}{OVAL_FILLED}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{OVAL_FILLED}, 'Draw a filled oval.' ] ) ;
$Button{WIDGET}{OVAL_FILLED}->bind( '<Leave>', \&button::enter ) ;
=cut


$Button{WIDGET}{LINE} = $Frame->Button(
    -image   => $Const{LINE_IMAGE},
    -command => [ \&button::set_button, 'LINE' ],
    )->pack() ;
$Button{WIDGET}{LINE}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{LINE}, 'Draw a line.' ] ) ;
$Button{WIDGET}{LINE}->bind( '<Leave>', \&button::enter ) ;


$Button{WIDGET}{TRANSPARENT} = $Frame->Button(
    -image   => $Const{TRANSPARENT_IMAGE},
    -command => [ \&button::set_button, 'TRANSPARENT' ],
    )->pack() ;
$Button{WIDGET}{TRANSPARENT}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{TRANSPARENT},
      'Draw with transparent.' ] ) ;
$Button{WIDGET}{TRANSPARENT}->bind( '<Leave>', \&button::enter ) ;


foreach( 0..3 ) {
    my $name = "PALETTE_$_" ;
    $Button{WIDGET}{$name} = $Frame->Button(
        -image   => $Const{PALETTE_IMAGE},
        -bg      => $Opt{$name},
        -command => [ \&button::set_button, $name ],
        )->pack() ;
    $Button{WIDGET}{$name}->bind( '<3>', [ \&button::choose_colour, $name ] ) ;
    $Button{WIDGET}{$name}->bind( '<Enter>', 
        [ \&button::enter, $Button{WIDGET}{$name}, 
          'Draw with colour COLOUR. Right click to change colour.' ] ) ;
    $Button{WIDGET}{$name}->bind( '<Leave>', \&button::enter ) ;
}


# Right hand button column.
$Frame = $ButtonFrame->Frame()->pack( 
                    -fill => 'y',
                    -side => 'left',
                    ) ;


# Brush begin.
$Button{WIDGET}{BRUSH} = $Frame->Button(
    -image   => $Const{BRUSH_IMAGE},
    -command => [ \&button::set_button, 'BRUSH' ],
    )->pack() ;
$Button{WIDGET}{BRUSH}->bind( '<Enter>', \&show_brush ) ;
$Button{WIDGET}{BRUSH}->bind( '<Leave>', \&button::enter ) ;

sub show_brush {

    my $i = $Opt{BRUSH_SIZE} == 2 ? 'medium' : 'wide' ;

    &button::enter( 
        $Button{WIDGET}{BRUSH},
        "Brush a $i sized group of pixels. Right click to change size." 
        ) ;
}

$RightMenu = $Win->Menu( 
                    -tearoff => 0,
                    -menuitems => [ 
                        [ 
                            Button   => 'Medium',  
                            -command => sub { $Opt{BRUSH_SIZE} = 2 }, 
                        ],
                        [ 
                            Button   => 'Wide',  
                            -command => sub { $Opt{BRUSH_SIZE} = 3 }, 
                        ],
                    ],
                    ) ;
$Button{WIDGET}{BRUSH}->bind( '<3>', [ \&brush_menu, $RightMenu ] ) ;

sub brush_menu {

    my( $win, $menu ) = @_ ;

    my $event = $win->XEvent ;

    $menu->post( $event->X, $event->Y ) ; 
    $Button{WIDGET}{BRUSH}->invoke 
    unless $Global{ACTIVE_IMPLEMENT} =~ /^BRUSH/o ;
}
# Brush end.


$Button{WIDGET}{TEXT} = $Frame->Button(
    -image   => $Const{TEXT_IMAGE},
    -command => [ \&button::set_button, 'TEXT' ],
    )->pack() ;
$Button{WIDGET}{TEXT}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{TEXT}, 'Write text (not implemented).' ] ) ;
$Button{WIDGET}{TEXT}->bind( '<Leave>', \&button::enter ) ;


$Button{WIDGET}{FLIP_VERTICAL} = $Frame->Button(
    -image   => $Const{FLIP_VERTICAL_IMAGE},
    -command => [ \&button::set_button, 'FLIP_VERTICAL' ],
    )->pack() ;
$Button{WIDGET}{FLIP_VERTICAL}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{FLIP_VERTICAL},
      'Flip the image vertically.' ] ) ;
$Button{WIDGET}{FLIP_VERTICAL}->bind( '<Leave>', \&button::enter ) ;


$Button{WIDGET}{RECTANGLE} = $Frame->Button(
    -image   => $Const{RECTANGLE_IMAGE},
    -command => [ \&button::set_button, 'RECTANGLE' ],
    )->pack() ;
$Button{WIDGET}{RECTANGLE}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{RECTANGLE},
      'Draw a rectangle.' ] ) ;
$Button{WIDGET}{RECTANGLE}->bind( '<Leave>', \&button::enter ) ;


$Button{WIDGET}{RECTANGLE_FILLED} = $Frame->Button(
    -image   => $Const{RECTANGLE_FILLED_IMAGE},
    -command => [ \&button::set_button, 'RECTANGLE_FILLED' ],
    )->pack() ;
$Button{WIDGET}{RECTANGLE_FILLED}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{RECTANGLE_FILLED},
      'Draw a filled rectangle.' ] ) ;
$Button{WIDGET}{RECTANGLE_FILLED}->bind( '<Leave>', \&button::enter ) ;


$Button{WIDGET}{GRAB_COLOUR} = $Frame->Button(
    -image   => $Const{PALETTE_IMAGE},
    -bg      => $Opt{GRAB_COLOUR} eq 'None' ? 
                    $Opt{GRID_BACKGROUND_COLOUR} :
                    $Opt{GRAB_COLOUR},
    -command => [ \&button::set_button, 'GRAB_COLOUR' ],
    )->pack() ;
$Button{WIDGET}{GRAB_COLOUR}->bind( '<3>', 
    [ \&button::choose_colour, 'GRAB_COLOUR' ] ) ;
$Button{WIDGET}{GRAB_COLOUR}->bind( '<Enter>', 
    [ \&button::enter, $Button{WIDGET}{GRAB_COLOUR},
      'Draw with grabbed colour COLOUR. Right click to change colour.' ] ) ;
$Button{WIDGET}{GRAB_COLOUR}->bind( '<Leave>', \&button::enter ) ;


foreach( 4..7 ) {
    my $name = "PALETTE_$_" ;
    $Button{WIDGET}{$name} = $Frame->Button(
        -image   => $Const{PALETTE_IMAGE},
        -bg      => $Opt{$name},
        -command => [ \&button::set_button, $name ],
        )->pack() ;
    $Button{WIDGET}{$name}->bind( '<3>', [ \&button::choose_colour, $name ] ) ;
    $Button{WIDGET}{$name}->bind( '<Enter>', 
        [ \&button::enter, $Button{WIDGET}{$name},
          'Draw with colour COLOUR. Right click to change colour.' ] ) ;
    $Button{WIDGET}{$name}->bind( '<Leave>', \&button::enter ) ;
}


1 ;
