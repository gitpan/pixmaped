#!/usr/bin/perl -w

# $Id: pixmaped-buttons.pl,v 1.27 1999/08/08 15:47:20 root Exp $

# (c) Mark Summerfield 1999. All s Reserved.
# May be used/distributed under the GPL.

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


&button::mkbutton( $Frame, 'PENCIL', 'Draw single pixels.' ) ;
&button::mkbutton( $Frame, 'SWAP', 
    'Swap the colour clicked with COLOUR throughout the image.' ) ;
&button::mkbutton( $Frame, 'ROTATE', '' ) ;

# Rotation start.
$Button{WIDGET}{ROTATE}->bind( '<Enter>', \&show_rotation ) ;

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


&button::mkbutton( $Frame, 'FLIP_HORIZONTAL', 'Flip the image horizontally.' ) ;
&button::mkbutton( $Frame, 'OVAL', 'Draw an oval.' ) ;
&button::mkbutton( $Frame, 'LINE', 'Draw a line.' ) ;
&button::mkbutton( $Frame, 'TRANSPARENT', 'Draw with transparent.' ) ;

foreach( 0..3 ) {
    my $name = "PALETTE_$_" ;

	&button::mkbutton( $Frame, $name, 
		'Draw with colour COLOUR. Right click to change colour.' ) ;
    $Button{WIDGET}{$name}->configure( 
        -bg    => $Opt{$name}, 
        -image => $Const{PALETTE_IMAGE},
        ) ;
    $Button{WIDGET}{$name}->bind( '<3>', [ \&button::choose_colour, $name ] ) ;
}


# Right hand button column.
$Frame = $ButtonFrame->Frame()->pack( 
                    -fill => 'y',
                    -side => 'left',
                    ) ;


# Brush begin.
&button::mkbutton( $Frame, 'BRUSH', '' ) ;
$Button{WIDGET}{BRUSH}->bind( '<Enter>', \&show_brush ) ;

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


&button::mkbutton( $Frame, 'FILL', 'Fill the area clicked with COLOUR.' ) ;
&button::mkbutton( $Frame, 'TEXT', 'Insert text - (Not implemented.)' ) ;
$Button{WIDGET}{TEXT}->configure( -state   => 'disabled', ) ;
&button::mkbutton( $Frame, 'FLIP_VERTICAL', 'Flip the image vertically.' ) ;
&button::mkbutton( $Frame, 'RECTANGLE', 'Draw a rectangle.' ) ;
&button::mkbutton( $Frame, 'RECTANGLE_FILLED', 'Draw a filled rectangle.' ) ;


&button::mkbutton( $Frame, 'GRAB_COLOUR', 
	'Draw with grabbed colour COLOUR. Right click to change colour.' ) ;
$Button{WIDGET}{GRAB_COLOUR}->configure(
    -bg => $Opt{GRAB_COLOUR} eq 'None' ? 
			   $Opt{GRID_BACKGROUND_COLOUR} :
               $Opt{GRAB_COLOUR},
	-image => $Const{PALETTE_IMAGE},
   ) ;
$Button{WIDGET}{GRAB_COLOUR}->bind( '<3>', 
    [ \&button::choose_colour, 'GRAB_COLOUR' ] ) ;


foreach( 4..7 ) {
    my $name = "PALETTE_$_" ;

	&button::mkbutton( $Frame, $name, 
		'Draw with colour COLOUR. Right click to change colour.' ) ;
    $Button{WIDGET}{$name}->configure( 
        -bg    => $Opt{$name}, 
        -image => $Const{PALETTE_IMAGE},
        ) ;
    $Button{WIDGET}{$name}->bind( '<3>', [ \&button::choose_colour, $name ] ) ;
}


1 ;
