#!/usr/bin/perl -w

# $Id: pixmaped-grid-commands.pl,v 1.59 1999/09/05 12:54:29 root Exp root $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;


package grid ;


my $Drag1 = 0 ;
my( $StartX, $StartY ) = ( undef, undef ) ;

my @Square ;


sub create { &_draw( 1 ) }
sub redraw { &_draw( 0 ) }

sub _draw {
    package main ;

    my $new = shift ;

    &cursor( 'watch' ) ;
    &grid::status( 'Redrawing...' ) ;
    my $time = time ; # DEBUG

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
        my $actualx = $x       * $Opt{GRID_SQUARE_LENGTH} ;
        my $actualX = $actualx + $Opt{GRID_SQUARE_LENGTH} ;
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            my $actualy = $y * $Opt{GRID_SQUARE_LENGTH} ;
            $ImageGrid[$x][$y] = 'None' 
            unless not $new and defined $ImageGrid[$x][$y] ;
            my $colour = $ImageGrid[$x][$y] ;
            $Square[$x][$y] = $Grid{CANVAS}->create(
                'rectangle', 
                $actualx,
                $actualy,
                $actualX,
                $actualy + $Opt{GRID_SQUARE_LENGTH},
                -fill    => ( $colour eq 'None' ) ? 
                            $Opt{GRID_BACKGROUND_COLOUR} : $colour, 
                -outline => $outline, 
                ) ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }

    if( $DEBUG ) {
        $time = time - $time ; 
        my( $s, $m, $h ) = (gmtime( $time ))[0..2] ; 
        $time = sprintf "Cleared %02d:%02d:%02d", $h, $m, $s ;
    }
    else {
        $time = '' ;
    }

    &cursor() ;
    &grid::status( $time ) ;
}


sub click1 {
    package main ;

    my( $canvas, $cx, $cy ) = @_ ;

    $cx = $canvas->canvasx( $cx ) if defined $cx ;
    $cy = $canvas->canvasy( $cy ) if defined $cy ;
   
    $StartX = $cx if defined $cx and not defined $StartX ;
    $cx     = $StartX unless $cx ;
    $StartY = $cy if defined $cy and not defined $StartY ;
    $cy     = $StartY unless $cy ;

    my $x = int( $cx / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y = int( $cy / $Opt{GRID_SQUARE_LENGTH} ) ;

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
            &cursor( 'watch' ) ;
            &grid::status( "Filling..." ) ;
            &shape::fill( $x, $y, $Global{COLOUR}, $ImageGrid[$x][$y] ) ;
            &cursor() ;
            &grid::status( "Filled with $Global{COLOUR}" ) ;
            last CASE ;
        }
        if( /^SWAP/o ) {
            &cursor( 'watch' ) ;
            &grid::status( "Swapping colours..." ) ;
            my $colour = $ImageGrid[$x][$y] ;
            &shape::swap( $Global{COLOUR}, $colour ) ;
            &cursor() ;
            &grid::status( "Swapped $colour for $Global{COLOUR}" ) ;
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

    my( $canvas, $cx, $cy ) = @_ ;
    my $x = int( $canvas->canvasx( $cx ) / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y = int( $canvas->canvasy( $cy ) / $Opt{GRID_SQUARE_LENGTH} ) ;

    local $_ = $Global{ACTIVE_BUTTON} ;

    if( /^PALETTE/o or /^TRANSPARENT/o or /^GRAB_COLOUR/o ) {
        &grid::click1( $Grid{CANVAS}, $cx, $cy ) if $Drag1 ;
    }
    elsif( defined $StartX and 
           ( /^LINE/o or /^RECTANGLE/o or /^CUT/o or /^COPY/o or /^OVAL/o ) ) {
        $Grid{CANVAS}->coords( 'SHAPE', $StartX, $StartY, $cx, $cy ) ;
    }
}


sub release1 {
    package main ;

    my( $canvas, $cx, $cy ) = @_ ;
    my $x = int( $canvas->canvasx( $cx ) / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y = int( $canvas->canvasy( $cy ) / $Opt{GRID_SQUARE_LENGTH} ) ;

    local $_ = $Global{ACTIVE_BUTTON} ;

    if( defined $StartX and $x ) {
        my( $sx, $sy ) = ( 
                           int( $StartX / $Opt{GRID_SQUARE_LENGTH} ), 
                           int( $StartY / $Opt{GRID_SQUARE_LENGTH} )
                         ) ; 
        if( /^LINE/o ) {
            &grid::status( 'Drawing line...' ) ;
            &shape::line( $sx, $sy, $x, $y ) ; 
            &grid::status( 'Drew line' ) ;
        }
        elsif( /^RECTANGLE_FILLED/o ) {
            &grid::status( 'Filling rectangle...' ) ;
            &shape::filled_rectangle( $sx, $sy, $x, $y ) ;
            &grid::status( 'Filled rectangle' ) ;
        }
        elsif( /^RECTANGLE/o ) {
            &grid::status( 'Drawing rectangle...' ) ;
            &shape::rectangle( $sx, $sy, $x, $y ) ;
            &grid::status( 'Drew rectangle' ) ;
        }
        elsif( /^OVAL_FILLED/o ) {
            &grid::status( 'Filling oval...' ) ;
            &shape::filled_oval( $sx, $sy, $x, $y ) ;
            &grid::status( 'Filled oval' ) ;
        }
        elsif( /^OVAL/o ) {
            &grid::status( 'Drawing oval...' ) ;
            &shape::oval( $sx, $sy, $x, $y ) ;
            &grid::status( 'Drew oval' ) ;
        }
        elsif( /^CUT/o ) {
            &edit::cut_rectangle( $sx, $sy, $x, $y ) ;
            $Button{WIDGET}{PENCIL}->invoke unless 
            $Global{ACTIVE_TOOL} eq 'pencil' ;
        }
        elsif( /^COPY/o ) {
            &edit::copy_rectangle( $sx, $sy, $x, $y ) ;
            $Button{WIDGET}{PENCIL}->invoke unless 
            $Global{ACTIVE_TOOL} eq 'pencil' ;
        }
    }
    $Grid{CANVAS}->delete( 'SHAPE' ) ;
    $StartX = undef ;
    $StartY = undef ;
}


sub click2 {
    package main ;

    my( $canvas, $cx, $cy ) = @_ ;
    my $x = int( $canvas->canvasx( $cx ) / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y = int( $canvas->canvasy( $cy ) / $Opt{GRID_SQUARE_LENGTH} ) ;

    &cursor( $Global{ACTIVE_TOOL} ) ;
    &grid::coords( $x, $y ) ;

    $Drag1 = 0 ;
}


sub click3 {
    # This is used to 'grab' the colour that the user has right clicked.
    package main ;

    my( $canvas, $cx, $cy ) = @_ ;
    my $x = int( $canvas->canvasx( $cx ) / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y = int( $canvas->canvasy( $cy ) / $Opt{GRID_SQUARE_LENGTH} ) ;

    my $colour        = $ImageGrid[$x][$y] ;
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

    my( $canvas, $cx, $cy ) = @_ ;
    my $x = int( $canvas->canvasx( $cx ) / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y = int( $canvas->canvasy( $cy ) / $Opt{GRID_SQUARE_LENGTH} ) ;

    &cursor( $Global{ACTIVE_TOOL} ) ;
    &grid::coords( $x, $y ) ;
}


sub leave {
    package main ;

    my( $canvas, $cx, $cy ) = @_ ;
    my $x = int( $canvas->canvasx( $cx ) / $Opt{GRID_SQUARE_LENGTH} ) ;
    my $y = int( $canvas->canvasy( $cy ) / $Opt{GRID_SQUARE_LENGTH} ) ;

    if( $x < 0 or $x >= $Opt{GRID_WIDTH} or 
        $y < 0 or $y >= $Opt{GRID_HEIGHT} ) { 
        $Grid{CANVAS}->delete( 'SHAPE' ) ;
        $Button{WIDGET}{PENCIL}->invoke ;
    }

    &cursor() ;
}


sub set_colour {
    package main ;

    my( $x, $y, $background, $outline, $dont_undo ) = @_ ;
    my $element = \$ImageGrid[$x][$y] ;

    $background = 'None' 
    if not defined $background or lc $background eq 'none' ;

    my $colour = defined $$element ? $$element : 'None' ;
    push @Undo, [ $x, $y, $colour ] 
    if ( $colour ne $background ) and ( not $dont_undo ) ;

    $$element = $background ;

    $background = $Opt{GRID_BACKGROUND_COLOUR} 
    if $background eq 'None' ;

    $outline ||= $Opt{GRID_OUTLINE_COLOUR} ;
    $outline = $Opt{SHOW_OUTLINE} ? $outline : undef ;

    eval {
        $Grid{CANVAS}->itemconfigure(
            $Square[$x][$y],
            -fill    => $background,
			-outline => $outline, 
            ) ;
    } ;
    if( $@ ) {
        if( $@ =~ /unknown color name/o ) {
            $Grid{CANVAS}->itemconfigure(
                $Square[$x][$y],
                -fill    => $Opt{GRID_BACKGROUND_COLOUR},
				-outline => $outline, 
                ) ;
            $$element = 'None' ;
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
        my $colour = $ImageGrid[$x][$y] || '' ;
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
