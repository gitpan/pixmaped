#!/usr/bin/perl -w

# $Id: pixmaped-button-commands.pl,v 1.31 1999/03/20 18:09:56 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package button ;


sub raise_others {
    package main ;

    my( $key, $relief ) = @_ ;

    my $palette = ( $key =~ /^PALETTE/o     or 
                    $key =~ /^TRANSPARENT/o or
                    $key =~ /^GRAB_COLOUR/o ) ? 1 : 0 ;

    return if $relief eq 'raised' ;

    local $_ ;
    foreach( keys %{$Button{WIDGET}} ) {
        next if $key eq $_ ; 
        if( /^PALETTE/o or /^TRANSPARENT/o or /^GRAB_COLOUR/o ) { 
            next unless $palette ;
        }
        if( /^BRUSH/o or /^PENCIL/o ) {
            next if $palette ;
        }
        if( /^SWAP/o or /^FILL/o or 
            /^LINE/o or /^TEXT/o or /^OVAL/o or /^RECTANGLE/o ) {
            next if $palette ;
        }
        $Button{WIDGET}{$_}->configure( -relief => 'raised' ) ;
    }
}


sub set_relief {
    package main ;

    my $key = shift ;

    my $relief = $Button{WIDGET}{$key}->cget( -relief ) eq 'raised' ? 
                    'sunken' : 'raised' ;
    $Button{WIDGET}{$key}->configure( -relief => $relief ) ;
    &button::raise_others( $key, $relief ) ;

    $relief eq 'raised' ? 0 : 1 ;
}


sub enter {
    package main ;

    my $button = shift if ref $_[0] ;
    my $text   = shift ;

    $text = '' unless $text ;

    if( $text =~ /^Fill/o or $text =~ /^Swap/o ) {
        $text =~ s/COLOUR/$Global{COLOUR} or $Opt{GRAB_COLOUR}/eo ;
    }
    elsif( defined $button ) {
        my $colour = $button->cget( -bg ) ;
        $text =~ s/COLOUR/$colour/o ;
    }

    &cursor( 'left_ptr' ) ;
    &grid::status( $text ) ;
}


sub set_button {
    package main ;

    local $_ = shift ;

    CASE : {
        if( /^PALETTE/o or /^TRANSPARENT/o or /^GRAB_COLOUR/o ) {
            $Global{COLOUR} = $Opt{$_} if &button::set_relief( $_ ) ; 
            last CASE ;
        }
        if( /^BRUSH/o or /^PENCIL/o ) {
            if( &button::set_relief( $_ ) ) {
                $Global{ACTIVE_IMPLEMENT} = $_ ;
                $Global{ACTIVE_BUTTON}    = 'GRAB_COLOUR' ;
            }
            else {
                $Global{ACTIVE_IMPLEMENT} = 'PENCIL' ;
                &grid::status( '' ) ;
            }
            if( /^BRUSH/o ) {
                $Global{ACTIVE_TOOL} = 'spraycan' ;
            }
            else {
                $Global{ACTIVE_TOOL} = 'pencil' ;
            }
            last CASE ;
        }
        if( /^SWAP/o or /^FILL/o or 
            /^LINE/o or /^TEXT/o or /^OVAL/o or /^RECTANGLE/o ) {
            if( &button::set_relief( $_ ) ) {
                $Global{ACTIVE_BUTTON} = $_ ;
                $Global{ACTIVE_TOOL} = 'cross' ;
                $Global{ACTIVE_TOOL} = 'xterm'         if /^TEXT/o ; 
                $Global{ACTIVE_TOOL} = 'diamond_cross' if /^FILL/o ; 
                $Global{ACTIVE_TOOL} = 'rtl_logo'      if /^SWAP/o ; 
            }
            last CASE ;
        }
        if( /^ROTATE/o ) {
            &cursor( 'exchange' ) ;
            &grid::status( "Rotating $Opt{ROTATION} degrees..." ) ;
            push @Undo, [ undef, undef, undef ] ;
            &button::rotate_90 ;
            &button::rotate_90 if $Opt{ROTATION} >  90 ;
            &button::rotate_90 if $Opt{ROTATION} > 180 ;
            push @Undo, [ undef, 'rotation', undef ] ;
            &cursor( -1 ) ;
            &grid::status( '' ) ;
            last CASE ;
        }
        if( /^FLIP_VERTICAL/o ) {
            &cursor( 'sb_h_double_arrow' ) ;
            &grid::status( "Flipping vertically..." ) ;
            push @Undo, [ undef, undef, undef ] ;
            &button::flip_vertical ;
            push @Undo, [ undef, 'vertical flip', undef ] ;
            &cursor( -1 ) ;
            &grid::status( '' ) ;
            last CASE ;
        }
        if( /^FLIP_HORIZONTAL/o ) {
            &cursor( 'sb_v_double_arrow' ) ;
            &grid::status( "Flipping horizontally..." ) ;
            push @Undo, [ undef, undef, undef ] ;
            &button::flip_horizontal ;
            push @Undo, [ undef, 'horizontal flip', undef ] ;
            &cursor( -1 ) ;
            &grid::status( '' ) ;
            last CASE ;
        }
        DEFAULT : {
            print STDERR "Not implemented $_\n" ;
            last CASE ;
        }
    }
}


sub flip_horizontal {
    package main ;

    my @grid ;
    my $pivot_y = int( $Opt{GRID_HEIGHT} / 2 ) ;

    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y <= $pivot_y ; $y++ ) {
            $grid[$x][$y] = $Grid{SQUARES}[$x][$Opt{GRID_HEIGHT} - $y]{COLOUR} ;
            $grid[$x][$Opt{GRID_HEIGHT} - $y] = $Grid{SQUARES}[$x][$y]{COLOUR} ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            &grid::set_colour( $x, $y, $grid[$x][$y] ) ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub flip_vertical {
    package main ;

    my @grid ;
    my $pivot_x = int( $Opt{GRID_WIDTH} / 2 ) ;

    for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
        for( my $x = 0 ; $x <= $pivot_x ; $x++ ) {
            $grid[$x][$y] = $Grid{SQUARES}[$Opt{GRID_WIDTH} - $x][$y]{COLOUR} ;
            $grid[$Opt{GRID_WIDTH} - $x][$y] = $Grid{SQUARES}[$x][$y]{COLOUR} ;
        }
        &grid::coords( $y ) if $Opt{SHOW_PROGRESS} ; 
    }
    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            &grid::set_colour( $x, $y, $grid[$x][$y] ) ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub rotate_90 {
    package main ;

    # Algorithm taken from Advanced Perl Programming - from the Tetris rotate
    # block!

    my @grid ;
    my $pivot_x = int( $Opt{GRID_WIDTH}  / 2 ) ;
    my $pivot_y = int( $Opt{GRID_HEIGHT} / 2 ) ;

    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            my $new_x = $pivot_x + ( $y - $pivot_y ) ;
            my $new_y = $pivot_y - ( $x - $pivot_x ) ;
            next if $new_x < 0 or $new_y < 0 ;
            $grid[$new_x][$new_y] = $Grid{SQUARES}[$x][$y]{COLOUR} ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
        for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
            &grid::set_colour( $x, $y, $grid[$x][$y] ) ;
        }
        &grid::coords( $x ) if $Opt{SHOW_PROGRESS} ; 
    }
}


sub choose_colour {
    package main ;

    shift if ref $_[0] ; # Get rid of object reference.
    my $button = shift ;

    &cursor( 'clock' ) ;
    &grid::status( "Choosing colour..." ) ;
    
    my $col_dialog = $Win->ColourChooser( 
                        -colour      => $Opt{$button},
                        -transparent => 0,
                        ) ;
    my $colour     = $col_dialog->Show ;

    if( $colour ) {
        $Button{WIDGET}{$button}->configure( 
            -image => $Const{PALETTE_IMAGE},
            -bg    => $colour,
            ) ;
        $Global{COLOUR}     = $colour ;
        $Opt{$button}       = $colour ;
        $Global{WROTE_OPTS} = 0 ;
        $Button{WIDGET}{$button}->invoke ; 
    }

    &cursor( -1 ) ;
    &grid::status( '' ) ;
}


1 ;
