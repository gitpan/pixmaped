#!/usr/bin/perl -w

# $Id: pixmaped-menu.pl,v 1.13 1999/02/27 16:18:54 root Exp $

# (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

use strict ;

package main ;


my $MenuBar = $Win->Frame(
                -relief      => 'raised',
                -borderwidth => 2,
                )->pack( -anchor => 'nw', -fill => 'x' ) ;


$MenuFile = $MenuBar->Menubutton(
                -text      => 'File',
                -underline => 0,
                -tearoff   => 0,
                -menuitems => [ 
                    [ 
                        Button       => '~New',  
                        -accelerator => 'Ctrl+N',
                        -command     => \&file::new,
                    ],
                    [ 
                        Button       => '~Open...', 
                        -accelerator => 'Ctrl+O',
                        -command     => \&file::open,
                    ], 
                    [
                        Button       => '~Save',
                        -accelerator => 'Ctrl+S',
                        -command     => \&file::save,
                    ],
                    [
                        Button       => 'Save ~As...',
                        -command     => \&file::save_as,
                    ],
                    [
                        Separator    => '',
                    ],
                    [
                        Button       => '~Preferences...',
                        -command     => \&options::options, 
                    ],
                    [
                        Separator    => '',
                    ],
                    [
                        Button       => '~Quit',
                        -accelerator => 'Ctrl+Q',
                        -command     => \&file::quit,
                    ],
                    [
                        Separator    => '',
                    ],
                ]
                )->pack( -side => 'left' ) ;

for( my $i = 1 ; $i <= $Const{LAST_FILE_MAX} ; $i++ ) {
    $MenuFile->command(
        -label   => "~$i " . $Opt{"LAST_FILE_$i"},
        -command => [ \&file::open, $i ],
        ) ;
}


my $MenuEdit = $MenuBar->Menubutton(
                -text      => 'Edit',
                -underline => 0,
                -tearoff   => 0,
                -menuitems => [ 
                    [ 
                        Button       => '~Undo',  
                        -accelerator => 'Ctrl+Z',
                        -command     => \&edit::undo,
                    ],                    
                    [
                        Separator    => '',
                    ],
                    [ 
                        Button       => '~Copy',  
                        -accelerator => 'Ctrl+C',
                        -command     => \&edit::copy,
                    ],                    
                    [ 
                        Button       => 'C~ut',  
                        -accelerator => 'Ctrl+X',
                        -command     => \&edit::cut,
                    ],                    
                    [ 
                        Button       => '~Paste',  
                        -accelerator => 'Ctrl+V',
                        -command     => \&edit::paste,
                    ],                    
                 ]
                 )->pack( -side => 'left' ) ;


my $zoom = $Opt{GRID_SQUARE_LENGTH} ;

my $MenuImage = $MenuBar->Menubutton(
                -text      => 'Image',
                -underline => 0,
                -tearoff   => 0,
                -menuitems => [ 
                    [ 
                        Radiobutton  => '  ~2 x zoom',  
                        -variable    => \$zoom,
                        -value       => 2,
                        -command     => [ \&image::zoom, 2 ],
                    ],
                    [ 
                        Radiobutton  => '  ~3 x zoom',  
                        -variable    => \$zoom,
                        -value       => 3,
                        -command     => [ \&image::zoom, 3 ],
                    ],
                    [ 
                        Radiobutton  => '  ~4 x zoom',  
                        -variable    => \$zoom,
                        -value       => 4,
                        -command     => [ \&image::zoom, 4 ],
                    ],
                    [ 
                        Radiobutton  => '  ~5 x zoom',  
                        -variable    => \$zoom,
                        -value       => 5,
                        -command     => [ \&image::zoom, 5 ],
                    ],
                    [ 
                        Radiobutton  => '  ~6 x zoom',  
                        -variable    => \$zoom,
                        -value       => 6,
                        -command     => [ \&image::zoom, 6 ],
                    ],
                    [ 
                        Radiobutton  => '  ~8 x zoom',  
                        -variable    => \$zoom,
                        -value       => 8,
                        -command     => [ \&image::zoom, 8 ],
                    ],
                    [ 
                        Radiobutton  => '1~0 x zoom',  
                        -variable    => \$zoom,
                        -value       => 10,
                        -command     => [ \&image::zoom, 10 ],
                    ],
                    [ 
                        Radiobutton  => '~12 x zoom',  
                        -variable    => \$zoom,
                        -value       => 12,
                        -command     => [ \&image::zoom, 12 ],
                    ],
                    [ 
                        Radiobutton  => '14 x zoo~m',  
                        -variable    => \$zoom,
                        -value       => 14,
                        -command     => [ \&image::zoom, 14 ],
                    ],
                    [ 
                        Radiobutton  => '16 x ~zoom',  
                        -variable    => \$zoom,
                        -value       => 16,
                        -command     => [ \&image::zoom, 16 ],
                    ],
                    [
                        Separator    => '',
                    ],
                    [ 
                        Button       => 'Re~size...',  
                        -command     => \&resize::resize,
                    ],                    
                ]
                )->pack( -side => 'left' ) ;


my $MenuHelp = $MenuBar->Menubutton(
                -text      => 'Help',
                -underline => 0,
                -tearoff   => 0,
                -menuitems => [ 
                    [ 
                        Button       => '~Help',  
                        -accelerator => 'F1',
                        -command     => \&help::help,
                    ],
                    [
                        Button       => '~About',
                        -command     => \&help::about,
                    ],
                ]
                )->pack( -side => 'left' ) ;


1 ;
