#!/usr/bin/perl -w

# $Id: pixmaped-keys.pl,v 1.2 1999/02/27 09:41:59 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


# Key bindings for the main window. 
$Win->bind( '<F1>',        \&help::help ) ;
$Win->bind( '<Control-c>', \&edit::copy ) ;
$Win->bind( '<Control-m>', \&edit::mark ) ;
$Win->bind( '<Control-n>', \&file::new ) ;
$Win->bind( '<Control-o>', \&file::open ) ;
$Win->bind( '<Control-q>', \&file::quit ) ;
$Win->bind( '<Control-s>', \&file::save ) ;
$Win->bind( '<Control-v>', \&edit::paste ) ;
$Win->bind( '<Control-x>', \&edit::cut ) ;
$Win->bind( '<Control-z>', \&edit::undo ) ;

=pod
$Win->bind( '<Up>',        \&action::move_up ) ;
$Win->bind( '<k>',         \&action::move_up ) ;     # vi
$Win->bind( '<Down>',      \&action::move_down ) ;
$Win->bind( '<j>',         \&action::move_down ) ;   # vi
$Win->bind( '<Left>',      \&action::move_left ) ;
$Win->bind( '<h>',         \&action::move_left ) ;   # vi
$Win->bind( '<Right>',     \&action::move_right ) ;
$Win->bind( '<l>',         \&action::move_right ) ;  # vi
=cut


1 ;
