#!/usr/bin/perl -w

# $Id: pixmaped-resize.pl,v 1.17 1999/03/16 20:40:29 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package resize ;


my $ResizeWin ; 
my %Button ;

my %Action = (
        0 => sub { },
        A => \&resize_width_reduce_left,
        B => \&resize_width_reduce_right, 
        C => \&resize_width_reduce_both,
        D => \&resize_width_add_left,
        E => \&resize_width_add_right,
        F => \&resize_width_add_both, 
        G => \&resize_height_reduce_top,
        H => \&resize_height_reduce_bottom,
        I => \&resize_height_reduce_both,
        J => \&resize_height_add_top,
        K => \&resize_height_add_bottom,
        L => \&resize_height_add_both,
        ) ;

my( $NewWidth, $NewHeight ) ;
my( $WidthAction, $HeightAction ) = ( 0, 0 ) ;


sub resize {
    package main ;

    &cursor( 'clock' ) ;
    &grid::status( 'Resizing image...' ) ;

    # Start with existing values.
    $NewWidth  = $Opt{GRID_WIDTH}  ;
    $NewHeight = $Opt{GRID_HEIGHT} ;

    # Set up the resize window. 
    $ResizeWin = $Win->Toplevel() ;
    $ResizeWin->title( 'Pixmaped Resize' ) ;
    $ResizeWin->protocol( "WM_DELETE_WINDOW", [ \&resize::close, 0 ] ) ;

    &resize::key_bindings ;

    my $row = 0 ;

    # Scales.
    my $scale ; 

    $scale = &resize::create_scale(
        $Const{GRID_WIDTH_MIN}, $Const{GRID_WIDTH_MAX}, 
        10, "New image width (pixels)", $row ) ;
    $scale->configure( 
        -variable => \$NewWidth,
        -command  => \&resize::set_width_buttons,
        ) ;
    $scale->focus ;
    $row += 2 ;

    $scale = &resize::create_scale(
        $Const{GRID_HEIGHT_MIN}, $Const{GRID_HEIGHT_MAX}, 
        10, "New image height (pixels)", $row ) ;
    $scale->configure( 
        -variable => \$NewHeight,
        -command  => \&resize::set_height_buttons,
        ) ;
    $row += 2 ;
     
    $ResizeWin->Label( -text => 'Change Width' 
            )->grid( -row => $row++, -column => 0, -columnspan => 3 ) ;

    my $Frame = $ResizeWin->Frame()->grid( 
                    -row        => $row++, 
                    -column     => 0,
                    -columnspan => 3,
                    ) ;

    foreach my $w ( 'A'..'F' ) {
        $Button{$w} = $Frame->Button(
            -image  => $Const{"RESIZE_${w}_IMAGE"},
            -command => [ \&resize::width_action, $w ],
            )->pack( -side => 'left' ) ;
    }

    $ResizeWin->Label( -text => 'Change Height' )->
        grid( -row => $row++, -column => 0, -columnspan => 3 ) ;

    $Frame = $ResizeWin->Frame()->grid( 
                    -row        => $row++, 
                    -column     => 0,
                    -columnspan => 3,
                    ) ;

    foreach my $h ( 'G'..'L' ) {
        $Button{$h} = $Frame->Button(
            -image  => $Const{"RESIZE_${h}_IMAGE"},
            -command => [ \&resize::height_action, $h ],
            )->pack( -side => 'left' ) ;
    }
 
    $Frame = $ResizeWin->Frame()->grid( 
                    -row        => $row++, 
                    -column     => 0,
                    -columnspan => 3,
                    ) ;

    # Save button.
    $Frame->Button(
        -text      => 'Resize',
        -underline => 0,
        -width     => $Const{BUTTON_WIDTH},
        -command   => [ \&resize::close, 1 ],
        )->pack( -pady => 5, -side => 'left' ) ;

    # Cancel button.
    $Frame->Button(
        -text      => 'Cancel',
        -underline => 0,
        -width     => $Const{BUTTON_WIDTH},
        -command   => [ \&resize::close, 0 ],
        )->pack( -side => 'left' ) ;
}


sub create_scale {
    my( $min, $max, $interval, $title, $row ) = @_ ;

    my $scale = $ResizeWin->Scale( 
        -orient       => 'horizontal',
        -from         => $min,
        -to           => $max,
        -tickinterval => $interval,
        -label        => $title,
        '-length'     => 300,
        )->grid( -row => $row, -column => 0, -rowspan => 2, -columnspan => 3 ) ;

    $scale ;
}


sub key_bindings {

    # Cancel keygrid bindings.
    $ResizeWin->bind( '<Alt-c>',     [ \&close, 0 ] ) ;
    $ResizeWin->bind( '<Control-c>', [ \&close, 0 ] ) ;
    $ResizeWin->bind( '<Escape>',    [ \&close, 0 ] ) ;

    # Save keygrid bindings.
    $ResizeWin->bind( '<Alt-r>',     [ \&close, 1 ] ) ;
    $ResizeWin->bind( '<Control-r>', [ \&close, 1 ] ) ;
    $ResizeWin->bind( '<Return>',    [ \&close, 1 ] ) ;
}


sub set_height_buttons {
    package main ;
  
    foreach my $i ( 'G'..'L' ) {
        $Button{$i}->configure( -state => 'disabled' ) ;
    }

    if( $NewHeight < $Opt{GRID_HEIGHT} ) {
        $Button{G}->configure( -state => 'active' ) ;
        $Button{H}->configure( -state => 'active' ) ;
        $Button{I}->configure( -state => 'active' ) ;
        $HeightAction = 'H' if $HeightAction =~ /[0J-L]/o ;
    }
    elsif( $NewHeight > $Opt{GRID_HEIGHT} ) {
        $Button{J}->configure( -state => 'active' ) ;
        $Button{K}->configure( -state => 'active' ) ;
        $Button{L}->configure( -state => 'active' ) ;
        $HeightAction = 'K' if $HeightAction =~ /[0G-I]/o ;
    }

    $HeightAction = 0 if $NewHeight == $Opt{GRID_HEIGHT} ;
    &resize::height_action( $HeightAction ) ;
}


sub set_width_buttons {
    package main ;

    foreach my $i ( 'A'..'F' ) {
        $Button{$i}->configure( -state => 'disabled' ) ;
    }
 
    if( $NewWidth < $Opt{GRID_WIDTH} ) {
        $Button{A}->configure( -state => 'active' ) ;
        $Button{B}->configure( -state => 'active' ) ;
        $Button{C}->configure( -state => 'active' ) ;
        $WidthAction = 'B' if $WidthAction =~ /[0D-F]/o ;
    }
    elsif( $NewWidth > $Opt{GRID_WIDTH} ) {
        $Button{D}->configure( -state => 'active' ) ;
        $Button{E}->configure( -state => 'active' ) ;
        $Button{F}->configure( -state => 'active' ) ;
        $WidthAction = 'E' if $WidthAction =~ /[0A-C]/o ;
    }

    $WidthAction = 0 if $NewWidth == $Opt{GRID_WIDTH} ;
    &resize::width_action( $WidthAction ) ;
}


sub width_action {
    package main ;

    shift if ref $_[0] ; # Some callers include an object ref.

    my $action = shift ;
    $WidthAction = $action if $action ;

    foreach my $i ( 'A'..'F' ) {
        next if $i eq $WidthAction ;
        $Button{$i}->configure( -relief => 'raised' ) ;
    }
    $Button{$action}->configure( -relief => 'sunken' ) 
    if $action and $NewWidth != $Opt{GRID_WIDTH} ;
}


sub height_action {
    package main ;

    shift if ref $_[0] ; # Some callers include an object ref.

    my $action = shift ;
    $HeightAction = $action if $action ;

    foreach my $i ( 'G'..'L' ) {
        next if $i eq $HeightAction ;
        $Button{$i}->configure( -relief => 'raised' ) ;
    }
    $Button{$action}->configure( -relief => 'sunken' ) 
    if $action and $NewHeight != $Opt{GRID_HEIGHT} ;
}


sub close {
    package main ;

    shift if ref $_[0] ; # Some callers include an object ref.
    my $save = shift ;

    if( $save ) {
        if( ( $NewWidth  != $Opt{GRID_WIDTH} ) or
            ( $NewHeight != $Opt{GRID_HEIGHT} ) ) {

            $main::Global{WROTE_IMAGE} = 0 
            unless $main::Global{FILENAME} =~ /^$main::Const{FILENAME}/o ;

            if( $WidthAction ) {
                &{$Action{$WidthAction}} ;
                $Image{WIDTH}  = $Opt{GRID_WIDTH}  = $NewWidth ;
                &grid::redraw ;
            }

            if( $HeightAction ) {
                &{$Action{$HeightAction}} ;
                $Image{HEIGHT} = $Opt{GRID_HEIGHT} = $NewHeight ;
                &grid::redraw ;
            }

            &write_opts ;
        }
    }

    &cursor( -1 ) ;
    &grid::status( '' ) ;
    $ResizeWin->destroy ;
}


sub resize_width_reduce_right {
    package main ;

    for( my $x = $NewWidth ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub resize_width_reduce_left {
    package main ;

    my $xborder = $Opt{GRID_WIDTH} - $NewWidth ; 

    for( my $x = $xborder ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            $Grid{SQUARES}[$x - $xborder][$y]{COLOUR} = 
				$Grid{SQUARES}[$x][$y]{COLOUR} ;
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' if $x > $xborder ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub resize_width_reduce_both {
    package main ;

    my $newwidth = $NewWidth ;
    $NewWidth    = int( $Opt{GRID_WIDTH} - 
                        ( ( $Opt{GRID_WIDTH} - $NewWidth ) / 2 ) ) ;
    &resize::resize_width_reduce_left ;
    $NewWidth    = $newwidth ;
    &resize::resize_width_reduce_right ;
}


sub resize_width_add_left {
    package main ;

    my $xborder = $NewWidth - $Opt{GRID_WIDTH} ; 

    for( my $x = $Opt{GRID_WIDTH} - 1 ; $x >= 0 ; $x-- ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            $Grid{SQUARES}[$x + $xborder][$y]{COLOUR} = 
				$Grid{SQUARES}[$x][$y]{COLOUR} ;
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' if $x < $xborder ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub resize_width_add_right {
    # No action necessary.
}


sub resize_width_add_both {
    package main ;

    my $newwidth = $NewWidth ;
    $NewWidth    = int( $Opt{GRID_WIDTH} - 
                        ( ( $Opt{GRID_WIDTH} - $NewWidth ) / 2 ) ) ;
    &resize::resize_width_add_left ;
    $NewWidth    = $newwidth ;
}


sub resize_height_reduce_top {
    package main ;

    my $yborder = $Opt{GRID_HEIGHT} - $NewHeight ; 

    for( my $y = $yborder ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
        for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
            $Grid{SQUARES}[$x][$y - $yborder]{COLOUR} = 
				$Grid{SQUARES}[$x][$y]{COLOUR} ;
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' if $y > $yborder ;
        }
        &grid::coords( $y ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub resize_height_reduce_bottom {
    package main ;

    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = $NewHeight ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub resize_height_reduce_both {
    package main ;

    my $newheight = $NewHeight ;
    $NewHeight    = int( $Opt{GRID_HEIGHT} - 
                        ( ( $Opt{GRID_HEIGHT} - $NewHeight ) / 2 ) ) ;
    &resize::resize_height_reduce_top ;
    $NewHeight    = $newheight ;
    &resize::resize_height_reduce_bottom ;
}


sub resize_height_add_top {
    package main ;

    my $yborder = $NewHeight - $Opt{GRID_HEIGHT} ; 

    for( my $y = $Opt{GRID_HEIGHT} - 1 ; $y >= 0 ; $y-- ) {
        for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
            $Grid{SQUARES}[$x][$y + $yborder]{COLOUR} = 
				$Grid{SQUARES}[$x][$y]{COLOUR} ;
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' if $y < $yborder ;
        }
        &grid::coords( $y ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub resize_height_add_bottom {
    # No action necessary.
}


sub resize_height_add_both {
    package main ;

    my $newheight = $NewHeight ;
    $NewHeight    = int( $Opt{GRID_HEIGHT} - 
                        ( ( $Opt{GRID_HEIGHT} - $NewHeight ) / 2 ) ) ;
    &resize::resize_height_add_top ;
    $NewHeight    = $newheight ;
}

 
1 ;
