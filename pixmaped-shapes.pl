#!/usr/bin/perl -w

# $Id: pixmaped-shapes.pl,v 1.7 1999/02/27 14:12:56 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package shape ;


sub line {
    package main ;

    my( $x0, $y0, $x1, $y1, $dont_undo ) = @_ ;

    push @Undo, [ undef, undef, undef ] unless $dont_undo ;

    if( $x0 == $x1 ) {
        ( $y0, $y1 ) = ( $y1, $y0 ) if $y0 > $y1 ;

        for( my $y = $y0 ; $y <= $y1 ; $y++ ) {
            &grid::set_colour( $x0, $y, $Global{COLOUR} ) ;
        }
    }
    else {
        # Line algorithm from Computer Graphics Principles and Practice.
        ( $x0, $y0, $x1, $y1 ) = ( $x1, $y1, $x0, $y0 ) if $x0 > $x1 ; 

        my $dy = $y1 - $y0 ;
        my $dx = $x1 - $x0 ;
        my $m  = $dx == 0 ? $dy : $dy/$dx ;
        my $y  = $y0 ;

        for( my $x = $x0 ; $x <= $x1 ; $x++ ) {
            &grid::set_colour( $x, int $y, $Global{COLOUR} ) ;
            $y += $m ;
        }
    }

    push @Undo, [ undef, 'line', undef ] unless $dont_undo ;
}


sub oval {
    package main ; 

    my( $x0, $y0, $x1, $y1 ) = @_ ;

    ( $x0, $y0, $x1, $y1 ) = ( $x1, $y1, $x0, $y0 ) if $x0 > $x1 ; 
 
    my $ox = $x1 > $x0 ? ( ( $x1 - $x0 ) / 2 ) + $x0 : 
                         ( ( $x0 - $x1 ) / 2 ) + $x1 ;
    my $oy = $y1 > $y0 ? ( ( $y1 - $y0 ) / 2 ) + $y0 : 
                         ( ( $y0 - $y1 ) / 2 ) + $y1 ;
    my $a  = abs( $x1 - $x0 ) / 2 ; 
    my $b  = abs( $y1 - $y0 ) / 2 ; 
    my $aa = $a ** 2 ;
    my $bb = $b ** 2 ;

    push @Undo, [ undef, undef, undef ] ;

    # Midpoint ellipse algorithm from Computer Graphics Principles and Practice.
    my $x = 0 ;
    my $y = $b ;
    my $d1 = $bb - ( $aa * $b ) + ( $aa / 4 ) ;
    &shape::ellipse_point( $ox, $oy, $x, $y ) ;

    while( ( $aa * ( $y - 0.5 ) ) > ( $bb * ( $x + 1 ) ) ) {
        if( $d1 < 0 ) {
            $d1 += ( $bb * ( ( 2 * $x ) + 3 ) ) ;
            ++$x ;
        }
        else {
            $d1 += ( ( $bb * ( ( 2 * $x ) + 3 ) ) +
                     ( $aa * ( ( -2 * $y ) + 2 ) ) ) ;
            ++$x ;
            --$y ;
        }
        &shape::ellipse_point( $ox, $oy, $x, $y ) ;
    }

    my $d2 = ( $bb * ( ( $x + 0.5 ) ** 2 ) ) + 
             ( $aa * ( ( $y - 1 ) ** 2 ) ) -
             ( $aa * $bb ) ;
    
    while( $y > 0 ) {
        if( $d2 < 0 ) {
            $d2 += ( $bb * ( ( 2 * $x ) + 2 ) ) +
                   ( $aa * ( ( -2 * $y ) + 3 ) ) ;
            ++$x ;
            --$y ;
        }
        else {
            $d2 += ( $aa * ( ( -2 * $y ) + 3 ) ) ;
            --$y ;
        }
        &shape::ellipse_point( $ox, $oy, $x, $y ) ;
    }

    push @Undo, [ undef, 'oval', undef ] ;
}


sub ellipse_point {
    package main ;

    my( $ox, $oy, $rx, $ry ) = @_ ;

    &grid::set_colour( $ox + $rx, $oy + $ry, $Global{COLOUR} ) ;
    &grid::set_colour( $ox - $rx, $oy - $ry, $Global{COLOUR} ) ;
    &grid::set_colour( $ox + $rx, $oy - $ry, $Global{COLOUR} ) ;
    &grid::set_colour( $ox - $rx, $oy + $ry, $Global{COLOUR} ) ;
}


sub filled_oval {
    package main ;

    warn "Filled oval not implemented yet.\n" ;
}


sub rectangle {
    package main ;

    my( $x0, $y0, $x1, $y1, $dont_undo ) = @_ ;

    push @Undo, [ undef, undef, undef ] unless $dont_undo ;

    # A rectangle is simply four lines...
    &shape::line( $x0, $y0, $x1, $y0, 1 ) ;
    &shape::line( $x1, $y0, $x1, $y1, 1 ) ;
    &shape::line( $x1, $y1, $x0, $y1, 1 ) ;
    &shape::line( $x0, $y1, $x0, $y0, 1 ) ;

    push @Undo, [ undef, 'rectangle', undef ] unless $dont_undo ;
}


sub filled_rectangle {
    package main ;

    my( $x0, $y0, $x1, $y1 ) = @_ ;

    ( $y0, $y1 ) = ( $y1, $y0 ) if $y0 > $y1 ;
    
    push @Undo, [ undef, undef, undef ] ;

    &shape::rectangle( $x0, $y0, $x1, $y1, 1 ) ; # Draw the outline.

    for( my $y = $y0 + 1 ; $y <= $y1 ; $y++ ) {
        &shape::line( $x0, $y, $x1, $y, 1 ) ; 
    }
    
    push @Undo, [ undef, 'filled rectangle', undef ] ;
}


1 ;
