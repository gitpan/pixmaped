#!/usr/bin/perl -w

# $Id: pixmaped-keys.pl,v 1.3 1999/03/01 19:32:18 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


# Key bindings for the main window. 
$Win->bind( '<F1>',        \&help::help ) ;
$Win->bind( '<Control-c>', \&edit::copy ) ;
$Win->bind( '<Control-n>', \&file::new ) ;
$Win->bind( '<Control-o>', \&file::open ) ;
$Win->bind( '<Control-q>', \&file::quit ) ;
$Win->bind( '<Control-s>', \&file::save ) ;
$Win->bind( '<Control-v>', \&edit::paste ) ;
$Win->bind( '<Control-x>', \&edit::cut ) ;
$Win->bind( '<Control-z>', \&edit::undo ) ;


1 ;
