#!/usr/bin/perl -w

# $Id: pixmaped-grid-commands.pl,v 1.49 1999/03/16 20:40:29 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;


package grid ;


my $Drag1 = 0 ;
my( $StartX, $StartY ) = ( undef, undef ) ;


sub create { &_draw( 1 ) }
sub redraw { &_draw( 0 ) }

sub _draw {
    package main ;

    my $new = shift ;

    &cursor( 'watch' ) ;
    &grid::status( 'Redrawing...' ) ;

    $Grid{CANVAS}->delete( 'all' ) ;

    $Grid{CANVAS}->configure(
        -width  => $Opt{GRID_WIDTH}  * $Opt{GRID_SQUARE_LENGTH},
        -height => $Opt{GRID_HEIGHT} * $Opt{GRID_SQUARE_LENGTH},
        -scrollregion   => [ 0, 0, 
                             $Opt{GRID_WIDTH}  * $Opt{GRID_SQUARE_LENGTH},
                             $Opt{GRID_HEIGHT} * $Opt{GRID_SQUARE_LENGTH},
                           ],
        ) ;

    my $outline = $Opt{SHOW_OUTLINE} ? $Opt{GRID_OUTLINE_COLOUR} : undef ;

    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        my $actualx = $x * $Opt{GRID_SQUARE_LENGTH} ;
        my $actualX = $actualx + $Opt{GRID_SQUARE_LENGTH} ;
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            my $actualy = $y * $Opt{GRID_SQUARE_LENGTH} ;
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' 
            unless defined $Grid{SQUARES}[$x][$y]{COLOUR} ;
            my $colour = $Grid{SQUARES}[$x][$y]{COLOUR} ;
            my $square = $Grid{CANVAS}->create(
                'rectangle', 
                $actualx,
                $actualy,
                $actualX,
                $actualy + $Opt{GRID_SQUARE_LENGTH},
                -fill    => ( $colour eq 'None' ) ? 
                            $Opt{GRID_BACKGROUND_COLOUR} : $colour, 
                -outline => $outline, 
                ) ;
            $Grid{SQUARES}[$x][$y]{SQUARE} = $square ; 
            $Grid{CANVAS}->bind( $square, '<Enter>', [ \&grid::enter, $x, $y ] ) ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }

    &cursor( -1 ) ;
    &grid::status( '' ) ;
}


sub click1 {
    package main ;

    my $win   = shift ;
    my $event = $win->XEvent ;
    my $cx    = $Grid{CANVAS}->canvasx( $event->x ) ;
    my $cy    = $Grid{CANVAS}->canvasy( $event->y ) ;
    my $x     = int( $cx / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y     = int( $cy / $Opt{GRID_SQUARE_LENGTH} ) ;

    local $_ = $Global{ACTIVE_BUTTON} ;

    CASE : {
        if( /^PALETTE/o or /^GRAB_COLOUR/o or /^TRANSPARENT/o ) { 
            my $colour = $Global{COLOUR} ;
               $colour = 'None' if /^TRANSPARENT/o ;
            &grid::set_colour( $x, $y, $colour ) ;
            if( $Global{ACTIVE_IMPLEMENT} =~ /^BRUSH/o ) {
                &grid::set_colour( $x + 1, $y, $colour ) 
                if $x + 1 < $Opt{GRID_WIDTH} ;
                &grid::set_colour( $x + 1, $y + 1, $colour ) 
                if $x + 1 < $Opt{GRID_WIDTH} and $y + 1 < $Opt{GRID_HEIGHT} ;
                &grid::set_colour( $x, $y + 1, $colour ) 
                if $y + 1 < $Opt{GRID_HEIGHT} ;
                if( $Opt{BRUSH_SIZE} > 2 ) {
                    &grid::set_colour( $x + 2, $y, $colour ) 
                    if $x + 2 < $Opt{GRID_WIDTH} ;
                    &grid::set_colour( $x + 2, $y + 1, $colour ) 
                    if $x + 2 < $Opt{GRID_WIDTH} and $y + 1 < $Opt{GRID_HEIGHT} ;
                    &grid::set_colour( $x + 2, $y + 2, $colour ) 
                    if $x + 1 < $Opt{GRID_WIDTH} and $y + 2 < $Opt{GRID_HEIGHT} ;
                    &grid::set_colour( $x, $y + 2, $colour ) 
                    if $y + 2 < $Opt{GRID_HEIGHT} ;
                    &grid::set_colour( $x + 1, $y + 2, $colour ) 
                    if $x + 1 < $Opt{GRID_WIDTH} and $y + 2 < $Opt{GRID_HEIGHT} ;
                }
            }
            last CASE ;
        }
        if( /^FILL/o ) {
            print STDERR "Fill at point ($x,$y).\n" ;
            last CASE ;
        }
        if( /^LINE/o ) {
            ( $StartX, $StartY ) = ( $cx, $cy ) ;
            $Grid{CANVAS}->createLine( 
                $cx, $cy, $cx, $cy,
                -width => 1, 
                -tags  => 'SHAPE',
                ) ;
            last CASE ;
        }
        if( /^OVAL/o ) {
            ( $StartX, $StartY ) = ( $cx, $cy ) ;
            $Grid{CANVAS}->createOval( 
                $cx, $cy, $cx, $cy,
                -width => 1, 
                -tags  => 'SHAPE',
                ) ;
            last CASE ;
        }
        if( /^RECTANGLE/o or /^CUT/o or /^COPY/o ) {
            ( $StartX, $StartY ) = ( $cx, $cy ) ;
            $Grid{CANVAS}->createRectangle( 
                $cx, $cy, $cx, $cy,
                -width => 1, 
                -tags  => 'SHAPE',
                ) ;
            last CASE ;
        }
        if( /^TEXT/o ) {
            # Prompt for text.
            print STDERR "Should prompt for the text.\n" ;
            &cursor( 'watch' ) ;
            &grid::status( "Writing text..." ) ;
            push @Undo, [ undef, undef, undef ] ;
            &image::text( $x, $y, 'Test' ) ;
            push @Undo, [ undef, 'text', undef ] ;
            &cursor( -1 ) ;
            &grid::status( '' ) ;
            $Button{WIDGET}{PENCIL}->invoke unless 
            $Global{ACTIVE_TOOL} eq 'pencil' ;
            # (Need to make right click give font menu.)
            last CASE ;
        }
        DEFAULT {
            print STDERR "No action for $_.\n" ;
            last CASE ;
        }
    }

    $Drag1 = 1 ;
}


sub motion1 {
    package main ;

    my $win   = shift ;
    my $event = $win->XEvent ;
    my $cx    = $Grid{CANVAS}->canvasx( $event->x ) ;
    my $cy    = $Grid{CANVAS}->canvasy( $event->y ) ;

    local $_ = $Global{ACTIVE_BUTTON} ;

    if( /^PALETTE/o or /^TRANSPARENT/o or /^GRAB_COLOUR/o ) {
        &grid::click1( $Grid{CANVAS} ) if $Drag1 ;
    }
    elsif( defined $StartX and 
           ( /^LINE/o or /^RECTANGLE/o or /^CUT/o or /^COPY/o or /^OVAL/o ) ) {
        $Grid{CANVAS}->coords( 'SHAPE', $StartX, $StartY, $cx, $cy ) ;
    }
}


sub release1 {
    package main ;

    my $win   = shift ;
    my $event = $win->XEvent ;
    my $x     = int( $Grid{CANVAS}->canvasx( $event->x ) / 
                     $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y     = int( $Grid{CANVAS}->canvasy( $event->y ) / 
                     $Opt{GRID_SQUARE_LENGTH} ) ;

    local $_ = $Global{ACTIVE_BUTTON} ;

    if( defined $StartX and $Grid{CANVAS}->canvasx( $event->x ) ) {
        my( $sx, $sy ) = ( 
                           int( $StartX / $Opt{GRID_SQUARE_LENGTH} ), 
                           int( $StartY / $Opt{GRID_SQUARE_LENGTH} )
                         ) ; 
        if( /^LINE/o ) {
            &grid::status( 'Drawing line...' ) ;
            &shape::line( $sx, $sy, $x, $y ) ; 
            &grid::status( '' ) ;
        }
        elsif( /^RECTANGLE_FILLED/o ) {
            &grid::status( 'Filling rectangle...' ) ;
            &shape::filled_rectangle( $sx, $sy, $x, $y ) ;
            &grid::status( '' ) ;
        }
        elsif( /^RECTANGLE/o ) {
            &grid::status( 'Drawing rectangle...' ) ;
            &shape::rectangle( $sx, $sy, $x, $y ) ;
            &grid::status( '' ) ;
        }
        elsif( /^OVAL_FILLED/o ) {
            &grid::status( 'Filling oval...' ) ;
            &shape::filled_oval( $sx, $sy, $x, $y ) ;
            &grid::status( '' ) ;
        }
        elsif( /^OVAL/o ) {
            &grid::status( 'Drawing oval...' ) ;
            &shape::oval( $sx, $sy, $x, $y ) ;
            &grid::status( '' ) ;
        }
        elsif( /^CUT/o ) {
            &edit::cut_rectangle( $sx, $sy, $x, $y ) ;
        }
        elsif( /^COPY/o ) {
            &edit::copy_rectangle( $sx, $sy, $x, $y ) ;
        }
        $StartX = undef ;
    }
    $Grid{CANVAS}->delete( 'SHAPE' ) ;
}


sub click2 {
    package main ;

    my( $x, $y ) = split /[, ]/, $Grid{COORDS}->cget( -text ) ;
    my( $cx, $cy ) = ( $x * $Opt{GRID_SQUARE_LENGTH}, 
                       $y * $Opt{GRID_SQUARE_LENGTH} ) ;

    print STDERR "Middle clicked $x,$y=$Global{ACTIVE_BUTTON}\n" ;

    $Drag1 = 0 ;
}


sub click3 {
    # This is used to 'grab' the colour that the user has right clicked.
    package main ;

    my( $x, $y ) = split /[, ]/, $Grid{COORDS}->cget( -text ) ;
    my( $cx, $cy ) = ( $x * $Opt{GRID_SQUARE_LENGTH}, 
                       $y * $Opt{GRID_SQUARE_LENGTH} ) ;

    my $colour        = $Grid{SQUARES}[$x][$y]{COLOUR} ;
    $Global{COLOUR}   = $colour ;
    $Opt{GRAB_COLOUR} = $colour ;
    if( lc $colour eq 'none' ) {
        $Button{WIDGET}{GRAB_COLOUR}->configure( 
            -image => $Const{TRANSPARENT_IMAGE},
            -bg    => $Opt{GRID_BACKGROUND_COLOUR},
            ) ;
    }
    else {
        $Button{WIDGET}{GRAB_COLOUR}->configure( 
            -image => $Const{PALETTE_IMAGE},
            -bg    => $colour,
            ) ;
    }
    $Button{WIDGET}{GRAB_COLOUR}->invoke 
    if $Button{WIDGET}{GRAB_COLOUR}->cget( -relief ) eq 'raised' ; 

    $Drag1 = 0 ;
}


sub enter {
    package main ;

    shift if ref $_[0] ;

    my( $x, $y ) = @_ ; 

    &cursor( $Global{ACTIVE_TOOL} ) ;
    &grid::coords( $x, $y ) ;
}


sub leave {
    package main ;

    my( $x, $y ) = split /[, ]/, $Grid{COORDS}->cget( -text ) ;
    my( $cx, $cy ) = ( $x * $Opt{GRID_SQUARE_LENGTH}, 
                       $y * $Opt{GRID_SQUARE_LENGTH} ) ;

    if( $x < 0 or $x >= $Opt{GRID_WIDTH} or 
        $y < 0 or $y >= $Opt{GRID_HEIGHT} ) { 
        $Grid{CANVAS}->delete( 'SHAPE' ) ;
        $Button{WIDGET}{PENCIL}->invoke ;
    }

    &cursor( 0 ) ;
}


sub set_colour {
    package main ;

    my( $x, $y, $background, $outline, $dont_undo ) = @_ ;

    $background = 'None' 
    if not defined $background or lc $background eq 'none' ;

    my $colour = defined $Grid{SQUARES}[$x][$y]{COLOUR} ?
                         $Grid{SQUARES}[$x][$y]{COLOUR} : 'None' ;
    push @Undo, [ $x, $y, $colour ] 
    if ( $colour ne $background ) and ( not $dont_undo ) ;

    $Grid{SQUARES}[$x][$y]{COLOUR} = $background ;

    $background = $Opt{GRID_BACKGROUND_COLOUR} 
    if $background eq 'None' ;

    $outline ||= $Opt{GRID_OUTLINE_COLOUR} ;
    $outline = $Opt{SHOW_OUTLINE} ? $outline : undef ;

    eval {
        $Grid{CANVAS}->itemconfigure(
            $Grid{SQUARES}[$x][$y]{SQUARE},
            -fill    => $background,
			-outline => $outline, 
            ) ;
    } ;
    if( $@ ) {
        if( $@ =~ /unknown color name/o ) {
            $Grid{CANVAS}->itemconfigure(
                $Grid{SQUARES}[$x][$y]{SQUARE},
                -fill    => $Opt{GRID_BACKGROUND_COLOUR},
				-outline => $outline, 
                ) ;
            $Grid{SQUARES}[$x][$y]{COLOUR} = 'None' ;
            &grid::status( "Replaced unknown '$background' with transparent." ) ;
        }
        else {
            die $@ ;
        }
    } 
    $Global{WROTE_IMAGE} = 0 ;
} 


sub coords {
    package main ;

    my( $x, $y ) = @_ ;

    my $text = $x ;

    if( defined $y ) {
        my $colour = $Grid{SQUARES}[$x][$y]{COLOUR} || '' ;
        $colour    = 'None' if $colour eq $Opt{GRID_BACKGROUND_COLOUR} ;
        $colour    = uc $colour if substr( $colour, 0, 1 ) eq '#' ;
        $text .= ",$y $colour" ;
    }

    $Grid{COORDS}->configure( -text => $text ) ;
    $Grid{COORDS}->update ;

    &grid::flags ;
}


sub status {
    package main ;

    my $text = shift ;

    $Grid{STATUS}->configure( -text => $text ) ;
    $Grid{STATUS}->update ;

    &grid::flags ;
}


sub flags {
    package main ;

    my $modified = $Global{WROTE_IMAGE} ? ''  : '*' ;
    my $buffer   = $Global{BUFFER}      ? 'P' : '' ; 

    $Grid{FLAGS}->configure( -text => $modified . $buffer ) ;
    $Grid{FLAGS}->update ;
}


1 ;
