#!/usr/bin/perl -w

# $Id: pixmaped-xbm.pl,v 1.2 1999/02/20 18:29:16 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package xbm ;


sub save {
    package main ;

    my $filename = shift ;
    my $saved    = 1 ;

    &cursor( 1, 'watch' ) ;
    &grid::status( "Saving '$filename'..." ) ;

    eval {
        die 'Not implemented' ;
    } ;
    if( $@ ) {
        $saved  = 0 ;
        my $err = substr( $@, 0, rindex( $@, ' at' ) ) ;
        message( 'Warning', 'Save',"Failed to save '$filename':\n$err" ) ;
    }

    &cursor( -1 ) ;
    &grid::status( '' ) ;

    $saved ;
}


1 ;
