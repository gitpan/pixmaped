#!/usr/bin/perl -w

# $Id: pixmaped-pxd.pl,v 1.1 1999/03/20 16:29:10 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package pxd ;


sub load {
    package main ;

    my $filename = shift ;
    my $loaded   = 1 ;
    my( $xo, $yo ) ;

    eval {
        open( PXD , $filename ) or die $! ;
        @Buffer = () ;
		$Global{BUFFER} = 0 ;
        local $_  = <PXD> ;
        chomp ;
        ( $xo, $yo ) = split /,/ ;
        while( <PXD> ) {
            chomp ;
            push @Buffer, [ split /,/ ] ;
        }
        close PXD ;
#        print STDERR join "\n", map { join ",", @$_ } @Buffer ;
		$Global{BUFFER} = 1 ;
    } ;
    if( $@ ) {
        $loaded = 0 ;
        my $err = ":\n" . substr( $@, 0, rindex( $@, ' at' ) ) ;
        $err = '' if $err =~ /Failed to load/o ;
        message( 'Warning', 'Load',"Failed to load `$filename'$err" ) ;
    }
    else {
		&grid::status( "Loaded `$filename' into the clipboard. Paste to insert" ) ;
    }

    ( $loaded, $xo, $yo ) ;
}


sub save {
    package main ;

    my( $filename, $from_clipboard, $xo, $yo ) = @_ ;
    my $saved = 1 ;

    $xo = 0 unless defined $xo ;
    $yo = 0 unless defined $yo ;

    eval {
        open( PXD, ">$filename" ) or die $! ;
        $from_clipboard = 0 unless scalar @Buffer ;
        print PXD "$xo,$yo\n" ;
        if( $from_clipboard ) {
			foreach my $br ( @Buffer ) { 
				my( $x, $y, $colour ) = @$br ;
				print PXD "$x,$y,$colour\n" ;
			}
		}
		else {
		    for( my $x = 0 ; $x < $Opt{GRID_WIDTH} ; $x++ ) {
				for( my $y = 0 ; $y < $Opt{GRID_HEIGHT} ; $y++ ) {
					print PXD "$x,$y,$Grid{SQUARES}[$x][$y]{COLOUR}\n" ;
			    }
			 }
	    }
        close PXD ;
    } ;
    if( $@ ) {
        $saved  = 0 ;
        my $err = substr( $@, 0, rindex( $@, ' at' ) ) ;
        message( 'Warning', 'Save',"Failed to save `$filename':\n$err" ) ;
    }

    $saved ;
}


1 ;

