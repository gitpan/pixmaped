#!/usr/bin/perl -w

# $Id: pixmaped-gif-fake.pl,v 1.3 1999/12/13 19:26:06 root Exp root $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;

package gif ;

sub load {
    package main ;

    message( 'Warning', 'Load',"Load gif/xbm not available - no GD library found" ) ;
}

sub save {
    package main ;

    message( 'Warning', 'Save',"Save gif not available - no GD library found" ) ;
}

1 ;
