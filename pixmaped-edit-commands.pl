#!/usr/bin/perl -w

# $Id: pixmaped-edit-commands.pl,v 1.20 1999/12/13 19:26:06 root Exp root $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;

package edit ;

my( @Buffer, $ox0, $oy0, $ox1, $oy1 ) ;


sub undo {
    package main ;

    if( not scalar @Undo ) {
        $Global{WROTE_IMAGE} = 1 ;
    }
    else {
        my $ur = pop @Undo ;
        my( $x, $y, $colour ) = @$ur ;

        if( defined $x ) { # Undo just one pixel.
            &grid::set_colour( $x, $y, $colour, undef, 1 ) ;
        }
        else { # Undo a whole SHAPE.
            &cursor( 'box_spiral' ) ;
            &grid::status( "Undoing $y..." ) ;
            while( 1 ) {
                last unless scalar @Undo ;
                my $ur = pop @Undo ;
                my( $x, $y, $colour ) = @$ur ;
                last unless defined $x ; 
                &grid::set_colour( $x, $y, $colour, undef, 1 ) ;
                &grid::coords( $x, $y, $colour ) if $Opt{SHOW_PROGRESS} ; 
            }
            &cursor() ;
        }
    }
    &grid::status( '' ) ;
}

sub copy {
    package main ;

    $Global{ACTIVE_BUTTON} = 'COPY' ;
    $Global{ACTIVE_TOOL}   = 'cross' ;
    &cursor( 'cross' ) ;
    &grid::status( "Marking for copying..." ) ;
}

sub copy_rectangle {
    package main ;

    ( $ox0, $oy0, $ox1, $oy1 ) = @_ ;

    @Buffer = () ;
    $Global{BUFFER} = 0 ;
    
    &edit::copy_filled_rectangle( $ox0, $oy0, $ox1, $oy1 ) ;    
#    $Win->clipboardSet( join "\n", map { join ",", @$_ } @Buffer ) ; 
    &grid::status( '' ) ;
}

sub cut {
    package main ;

    $Global{ACTIVE_BUTTON} = 'CUT' ;
    $Global{ACTIVE_TOOL}   = 'cross' ;
    &cursor( 'cross' ) ;
    &grid::status( "Marking for cutting..." ) ;
}

sub cut_rectangle {
    package main ;

    ( $ox0, $oy0, $ox1, $oy1 ) = @_ ;

    @Buffer = () ;
    $Global{BUFFER} = 0 ;
    
    &edit::copy_filled_rectangle( $ox0, $oy0, $ox1, $oy1, 1 ) ;    
#    $Win->clipboardSet( join "\n", map { join ",", @$_ } @Buffer ) ; 
    &grid::status( '' ) ;
}


sub paste {
    package main ;

    if( defined $Global{X} and defined $Global{Y} and defined $ox0 and defined $oy0 ) {
        push @Undo, [ undef, undef, undef ] ;
        my $xoffset = $Global{X} - $ox0 ;
        my $yoffset = $Global{Y} - $oy0 ;
        foreach my $br ( @Buffer ) { 
            my( $x, $y, $colour ) = @$br ;
            &grid::set_colour( $x + $xoffset, $y + $yoffset, $colour ) 
            unless $colour eq 'None' and not $Opt{INSERT_TRANSPARENT} ;
        }
        push @Undo, [ undef, 'paste', undef ] ;
    }
    else {
        print STDERR "Nothing to paste.\n" ;
	}
    $Button{WIDGET}{PENCIL}->invoke 
    if $Button{WIDGET}{PENCIL}->cget( -relief ) eq 'raised' ; 
}

#sub paste_from_clipboard {
#    package main ;
#    
#    my $buffer = $Win->clipboardGet ;
#    @Buffer = map { [ split "," ] } split "\n", $buffer 
#    if defined $buffer ; 
#    &edit::paste ;
#}

sub copy_line {
    package main ;

    my( $x0, $y0, $x1, $y1, $clear ) = @_ ;

    if( $x0 == $x1 ) {
        ( $y0, $y1 ) = ( $y1, $y0 ) if $y0 > $y1 ;

        for( my $y = $y0 ; $y <= $y1 ; $y++ ) {
            push @Buffer, [ $x0, $y, $ImageGrid[$x0][$y] ] ;
            &grid::set_colour( $x0, $y, 'None' ) if $clear ; 
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
            push @Buffer, [ $x, $y, $ImageGrid[$x][$y] ] ;
            &grid::set_colour( $x, $y, 'None' ) if $clear ; 
            $y += $m ;
        }
    }
    $Global{BUFFER} = 1 ;
}

sub copy_filled_rectangle {
    package main ;

    my( $x0, $y0, $x1, $y1, $clear ) = @_ ;

    ( $y0, $y1 ) = ( $y1, $y0 ) if $y0 > $y1 ;
   
    push @Undo, [ undef, undef, undef ] if $clear ;

    for( my $y = $y0 ; $y <= $y1 ; $y++ ) {
        &edit::copy_line( $x0, $y, $x1, $y, $clear ) ; 
    }

    push @Undo, [ undef, 'cut', undef ] if $clear ;
}

1 ;
