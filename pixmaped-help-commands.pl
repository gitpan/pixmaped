#!/usr/bin/perl -w

# $Id: pixmaped-help-commands.pl,v 1.39 1999/12/13 19:26:06 root Exp root $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the GPL.

use strict ;

package help ;

my $HelpWin ; 
my $TextBox ;

sub help {

    &main::cursor( 'clock' ) ;
    &grid::status( 'Showing help...' ) ;

    # Set up the help window and some bindings to close it.
    $HelpWin = $main::Win->Toplevel() ; 
    $HelpWin->title( 'Pixmaped Help' ) ;
    $HelpWin->protocol( "WM_DELETE_WINDOW", \&close ) ;
    $HelpWin->bind( '<q>',         \&close ) ;
    $HelpWin->bind( '<Alt-q>',     \&close ) ;
    $HelpWin->bind( '<Control-q>', \&close ) ;
    $HelpWin->bind( '<Escape>',    \&close ) ;

    # Set up the text widget.
    $TextBox = $HelpWin->Scrolled( 'Text', 
                    -background => 'white', 
                    -wrap       => 'word',
                    -scrollbars => 'ow',
                    -width      => 80, 
                    -height     => 40,
                    -takefocus  => 0,
                    )->pack( -fill => 'both', -expand => 'y' ) ;
    my $text = $TextBox->Subwidget( 'text' ) ;
    $text->configure( -takefocus => 1 ) ;
    $text->focus ;

    if( open HELP, $main::Const{HELP_FILE} ) {
		local $/ = '' ; # render_pod requires paragraphs.
		&tk::text::render_pod( $text, <HELP> ) ;
		close HELP ;
	}
	else {
		message( 
		    'Warning', 
		    'Help', 
		    "Cannot open help file `$main::Const{HELP_FILE}': $!"
		    ) ;
	}

    $text->configure( -state => 'disabled' ) ;
}

sub close {

    &main::cursor() ;
    &grid::status( '' ) ;
    $HelpWin->destroy ;
}

sub about {
    package main ;

    &cursor( 'clock' ) ;
    &grid::status( 'Showing about box...' ) ;

    my $text = <<__EOT__ ;
Pixmaped v $VERSION

summer\@perlpress.com

Copyright (c) Mark Summerfield 1999. 
All Rights Reserved.

May be used/distributed under the GPL.
__EOT__

    my $msg = $Win->MesgBox(
        -title => "Pixmaped - About",
        -text  => $text,
        ) ;
    $msg->Show ;
    
    &cursor() ;
    &grid::status( '' ) ;
}

1 ;
