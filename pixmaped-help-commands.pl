#!/usr/bin/perl -w

# $Id: pixmaped-help-commands.pl,v 1.29 1999/03/16 20:40:29 root Exp $

# Copyright (c) Mark Summerfield 1999. All Rights Reserved.
# May be used/distributed under the same terms as Perl.

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

    &set_text_tags ;

    # Read and render the help text.
    local $_ ;
    local $/   = '' ;
    my $inpod  = 0 ;
    my $indent = 0 ;
    my $bullet ;

    while( <DATA> ) {
        $inpod = 1, next if /^=pod/o ;
        $inpod = 0, next if /^=cut/o ;
        next unless $inpod ;
        next if /^#/o ;

        &body( "\n" ), next if /^$/o ;

        if( /^=head1 (.*)/o ) {
            &head1( "$1\n\n" ) ;
        }
        elsif( /^=head2 (.*)/o ) {
            &head2( "$1\n\n" ) ;
        }
        elsif( /^[ \t]/o ) {
            &code( $_ ) ; # Verbatim.
        }
        elsif( /^=over/o ) {
            $indent = 1 ;
        }
        elsif( /^=back/o ) {
            $indent = 0 ;
            $bullet = undef ;
        }
        elsif( /^=item(?:\s+(\S))?/o ) {
            if( not defined $bullet ) { # Starting a new list.
                $bullet = $1 ? $1 : '*' ;
            }
            elsif( $bullet =~ /^\d+$/o ) { # Bullet is numbered.
                ++$bullet ;
            }
            # else bullet so no action required.
            &body( "$bullet ", 'bold', 'indent' ) ;
        }
        else {
            my $tag = $indent ? 'indent' : undef ;
            s/\n/ /go unless /^[\t ]/o ;
            my @fragments = split /([BCI]<)([^>]+)>/, $_ ;
            if( scalar @fragments ) {
                while( 1 ) {
                    my $fragment = shift @fragments ; 
                    last unless defined $fragment ;
                    if( $fragment eq 'B<' ) {
                        &bold( shift @fragments, $tag ) ;
                    }
                    elsif( $fragment eq 'C<' ) {
                        &code( shift @fragments, $tag ) ;
                    }
                    elsif( $fragment eq 'I<' ) {
                        &italic( shift @fragments, $tag ) ;
                    }
                    else {
                        &body( $fragment, $tag ) ;
                    }
                }
                &body( "\n\n", $tag ) ;
            }
            else {
                &body( "$_\n\n", $tag ) ;
            }
        }
    }

   $text->configure( -state => 'disabled' ) ;
}


sub head1  { $TextBox->insert( 'end', shift, [ 'head1',  @_ ] ) }
sub head2  { $TextBox->insert( 'end', shift, [ 'head2',  @_ ] ) }
sub code   { $TextBox->insert( 'end', shift, [ 'code',   @_ ] ) }
sub bold   { $TextBox->insert( 'end', shift, [ 'bold',   @_ ] ) }
sub italic { $TextBox->insert( 'end', shift, [ 'italic', @_ ] ) }
sub body   { $TextBox->insert( 'end', shift, [ 'body',   @_ ] ) }


sub set_text_tags {

    # Set up some text styles for the help text. If any fonts are not
    # available or are missing we ignore the fact.
    eval {
        $TextBox->tagConfigure( 'head1',
            -font    => "-*-helvetica-bold-r-normal-*-*-240-*-*-*-*-*",
            -justify => 'center',
            -wrap => 'word',
            ) ;
    } ;
    $TextBox->tagConfigure( 'head1', -foreground => 'darkblue' ) ;

    eval {
        $TextBox->tagConfigure( 'head2',
            -font => "-*-helvetica-bold-r-normal-*-*-180-*-*-*-*-*",
            -wrap => 'word',
            ) ;
    } ;
    $TextBox->tagConfigure( 'head2', -foreground => 'darkgreen' ) ;

    eval {
        $TextBox->tagConfigure( 'body',
            -font => "-*-times-medium-r-normal-*-*-180-*-*-*-*-*",
            -wrap => 'word',
            -tabs => [ '2c' ],
            ) ;
    } ;

    eval {
        $TextBox->tagConfigure( 'bold',
            -font => "-*-times-bold-r-normal-*-*-180-*-*-*-*-*",
            ) ;
    } ;

    eval {
        $TextBox->tagConfigure( 'italic',
            -font => "-*-times-medium-i-normal-*-*-180-*-*-*-*-*",
            ) ;
    } ;
 
    eval {
        $TextBox->tagConfigure( 'code',
            -font => "-*-lucidatypewriter-medium-r-normal-*-*-140-*-*-*-*-*",
            -tabs => [ '1c' ],
            ) ;
    } ;
    $TextBox->tagConfigure( 'code', 
        -font => 'fixed',
        -tabs => [ '1c' ],
        ) if $@ ;

    $TextBox->tagConfigure( 'indent', -lmargin1 => 20, -lmargin2 => 35 ) ;
}
 

sub close {

    &main::cursor( -1 ) ;
    &grid::status( '' ) ;
    $HelpWin->destroy ;
}


sub about {
    package main ;

    &cursor( 'clock' ) ;
    &grid::status( 'Showing about box...' ) ;

    my $text = <<__EOT__ ;
Pixmaped v $VERSION

Copyright (c) Mark Summerfield 1999. 
All Rights Reserved.

May be used/distributed under the same terms as Perl.
__EOT__


    my $msg = $Win->MesgBox(
        -title => "About Pixmaped",
        -text  => $text,
        ) ;
    $msg->Show ;
    
    &cursor( -1 ) ;
    &grid::status( '' ) ;
}


1 ;

__DATA__

=pod

=head1 Pixmaped Help

Press <C<Escape>> or <C<q>> to close this help window; scroll using
the scrollbar, arrow keys, <C<PageUp>> or <C<PageDown>>.

=head2 Mouse

=over

=item *

B<Colour a pixel> - Left clicking a square colours that square with the colour
of the selected (sunken) palette button.

=item

B<Colouring many pixels> - Dragging with the left mouse button down, colours
all the squares the mouse passes over.

=item

B<`Grabbing' a pixel's colour> - Right clicking a square `grabs' the square's
colour (even transparent), and makes that colour the colour of the `grab
palette' button (which is next to the transparent button). From then on left
clicking a square will colour it in the `grabbed' colour. This means that it
is rarely necessary to use any of the other palette buttons since you just
right click existing squares that have the colours you want.

=item

B<Changing a palette button's colour> - Right clicking any palette button
including the grab palette button invokes the colour chooser dialogue which
allows you to set the colour by name or RGB value.

=item

B<Setting the brush width> - Right clicking the brush button pops up a menu
offering the choice of medium or wide brushstrokes.

=item

B<Setting the rotation angle> - Right clicking the rotation button pops up a
menu offering the choice of rotations.

=item

B<Cutting an area> - Press C<Ctrl-x> or choose C<Edit/Cut> from the menu, then
drag out a rectangle with the left mouse button over the area to cut.

=item

B<Copying an area> - Press C<Ctrl-c> or choose C<Edit/Copy> from the menu, then
drag out a rectangle with the left mouse button over the area to copy.

=item

B<Pasting an area> - After copying or cutting an area move the mouse to any
point on the image and press C<Ctrl-v> or choose C<Edit/Paste> from the menu.

=back 

=head2 Keystrokes

=over

=item *

C<Ctrl-c>	After selecting copy you drag a rectangle with the left mouse
button to mark an area which is then copied to the copy buffer.

=item

C<Ctrl-n>	Create a new wholly transparent image. You will be presented with
the Preferences dialogue which allows you to set the initial width, height and
zoom factor for the new image.

=item

C<Ctrl-o>	This will open an existing image file. You will be presented with
a file selection dialogue from which to choose the file. Pixmaped can
open C<.xpm> files; with C<GD.pm> it can also open C<.xbm> and C<.gif>
files; and with C<Image::Magick.pm> Pixmaped can open all file formats supported
by that module, including C<.bmp>, C<.dcx>, C<.dib>, C<.ico>,
C<.pbm>, C<.pcd>, C<.pcx>, C<.pict>, C<.png>, C<.ppm>, C<.rle>,
C<.sgi>, C<.tga>, group 3 fax format, and if you also have ghostscript
C<.eps>, C<.pdf> and C<.ps>. If you have C<Image::Magick.pm> you can also
open gzip compressed files, e.g. C<image.gif.gz>.
I<Note that not all formats that can be read can be written and vice versa.>

=item

C<Ctrl-q>	Quit Pixmaped (with prompt to save if necessary).

=item

C<Ctrl-s>	Save the current image. 

=item

C<Ctrl-v>	Paste the copy buffer into the image where the mouse is pointing.

=item

C<Ctrl-x>	After selecting cut you drag a rectangle with the left mouse
button to mark an area which is then cut to the copy buffer. (Pixels cut
become transparent).

=item

C<[F1]>	Invoke this help window.

=back

=head2 Status-bar

At the bottom of the main window is a status bar. It is divided into four
sections which are described below in left to right order. 

=over

=item 1

The first section is an actual size copy of the image at the time it was last
opened or saved whichever is the most recent - for new images it will be
blank until saved for the first time. Only C<.gif>, C<.xbm> and C<.xpm>'s
are displayed here; to see other formats actual size set the Image/Zoom
to Actual size. I<Note that sometimes transparent sections of
gifs display in colour, but they really are transparent, for example when
viewed in a Browser.> 

=item

The second section shows the x and y coordinates of the mouse when it is over
the canvas followed by the colour at that point. Note that `None'
signifies transparent.

=item

The third section shows two status indicators: an asterisk `B<*>' indicates that
the file has been modified (and that undo is possible); a `B<P>' indicates that
there is an image fragment in the copy buffer which can be pasted into the
image. Note that this only gets updated when the mouse is moved.

=item

The fourth section provides brief information, for example, if you pass the
mouse over any of the toolbar buttons a one line description of the function
of the button is shown here.

=back

=head2 Toolbar

To the left of the main window is a toolbar. Move the mouse over each toolbar
button to see its function - descriptions appear in the fourth section of the
Status-bar. Some buttons may be right-clicked, for example to change their
setting - this is noted in the description.

=head2 File Menu

=over

=item *

B<New> - This will create a new blank image. If you save it you will be prompted
for a filename with the B<Save As> dialogue.

=item

B<Open>	This will open an existing image file. You will be presented with
a file selection dialogue from which to choose the file. Pixmaped can
open C<.xpm> files; with C<GD.pm> it can also open C<.xbm> and C<.gif>
files; and with C<Image::Magick.pm> Pixmaped can open all file formats supported
by that module, including C<.bmp>, C<.dcx>, C<.dib>, C<.ico>
C<.pbm>, C<.pcd>, C<.pcx>, C<.pict>, C<.png>, C<.ppm>, C<.rle>,
C<.sgi>, C<.tga>, group 3 fax format, and if you also have ghostscript
C<.eps>, C<.pdf> and C<.ps>. If you have C<Image::Magick.pm> you can also
open gzip compressed files, e.g. C<image.gif.gz>.
I<Note that not all formats that can be read can be written and vice versa.>

=item

B<Save> - This will save the existing image. If the image is new you will be
prompted for a filename with the B<Save As> dialogue.

=item

B<Save As> - This will present you with a file selection dialogue. You select
the path and enter the new filename to which the image will be saved. The
file will be saved in the format determined by its suffix. Pixmaped
can save C<.xpm> and C<.ps> files; with C<GD.pm> it can also save C<.gif>
files; and with C<Image::Magick.pm> Pixmaped can save all the file formats
supported by that module including C<.bmp>, C<.dcx>, C<.dib>, 
C<.pbm>, C<.pcd>, C<.pcx>, C<.pict>, C<.png>, C<.ppm>, C<.sgi>, C<.tga>,
group 3 fax format, and if you also have ghostscript
C<.eps>, C<.pdf> and C<.ps>. If you have C<Image::Magick.pm> you can also
save gzip compressed files, e.g. C<image.gif.gz>.
I<Note that not all formats that can be read can be written and vice versa.>

=item

B<Preferences> - This will invoke the preferences dialogue; currently you can
set the default image size for new images and the default zoom factor.

=item

B<Quit> - This will quit the program. If the image has had unsaved changes you
will be prompted for a filename with the B<Save As> dialogue.

=item

B<1..9> - Pixmaped remembers the last nine files opened or saved. By
selecting one of these the file will be reopened. If the filename is I<(None)>
then the B<Open> dialogue will be invoked.

=back

=head2 Edit Menu

=over

=item *

B<Undo> - Undo the last action. Everything can be undone back until the point
where the file was opened or last saved whichever is most recent.

=item

B<Copy> - After selecting copy you drag a rectangle with the left mouse button
to mark an area which is then copied to the copy buffer. 

=item

B<Cut> - After selecting cut you drag a rectangle with the left mouse button
to mark an area which is then cut to the copy buffer. (Pixels cut become
transparent.)

=item

B<Paste> - Paste the copy buffer into the image where the mouse is pointing.

=back

Note that the copy buffer is preserved when you open an existing or create a
new file, so you can open an image, copy part of it, then open another file
and paste in the copied section. You can paste the copy buffer as many times
as you wish.

=head2 Image Menu

=over

=item *

B<Actual size> - show the image actual size.

=item *

I<n>B< x zoom> - zoom to I<n> times the image size.

=item

B<Resize> - resize the image; the image may be made larger or smaller with any
space inserted or removed from the side(s) the user specifies.

=back

=head2 Options Menu

=over

=item *

B<Show Outline> - Toggles between showing/hiding the grid outline. 

=back

=head2 Help Menu

=over

=item *

B<Help> - invoke this help screen.

=item

B<About> - invoke Pixmaped's about box.

=back

=head2 Preferences dialogue

This dialogue is invoked when you choose the C<File/New> menu option (or
press C<Ctrl-n>) and allows you to change the width, height and initial zoom
factor for the new image. (Images may be resized - see the Resize dialogue
later.) This dialogue may be used on an existing image, but it is recommended
that the C<Image> menu is used for changing the zoom factor or size of an
existing image. More preferences may be set in the preferences file described
later.

=head2 Resize dialogue

This dialogue is invoked when you choose the C<Image/Resize> menu option and
allows you to change the width and height of an image. If you change the width
of the image you may add/delete from the left, right or equally from both;
similarly if you change the height you may add/delete from the top, bottom or
equally from both.

=head2 Preferences file

Preferences should be set using the Preferences dialogue.
User preferences are stored in C<~/.pixmaped-opts> (C<PIXMAPED.INI> under Win32). 

Any preferences you change in this file take precedence over the default
preferences. To reinstate a default preference delete or comment out (with
C<#>) the preferences you wish to reinstate - the next time you run the
program the defaults will be back.

The preferences currently supported are listed below. They may be changed by
the user unless specified otherwise.

=over

=item 

C<BRUSH_SIZE> - `B<2>' means medium (2 x 2 pixels) brush; `B<3>' means wide (3
x 3 pixels) brush.

=item

C<DIR> - This is the initial working directory.

=item

C<GRAB_COLOUR> - The initial colour of the grab palette. 

=item

C<GRID_BACKGROUND_COLOUR> - The colour used by Pixmaped to signify
I<transparent>.

=item

C<GRID_HEIGHT> - The default grid height for new images.

=item

C<GRID_OUTLINE_COLOUR> - The colour used by Pixmaped between the grid squares.

=item

C<GRID_SQUARE_LENGTH> - The zoom factor, 2 = 2 x, etc.

=item

C<GRID_WIDTH> - The default grid width for new images.

=item

C<LAST_FILE> - I<Should not be changed.>

=item

C<LAST_FILE_>I<n> - The absolute paths and names of the I<n>th file used; the
last nine files opened or saved are listed here. (I<n> is in the range 1..9.)

=item

C<PALETTE_>I<n> - The colour of the I<n>th palette button. (I<n> is in the
range 0..7.) 

=item

C<ROTATION> - The default amount of rotation to use when the rotate button is
clicked; valid values are 90, 180 and 270 degrees.

=item

C<SHOW_OUTLINE> - Whether or not to show a grid outline; default is 1 (yes). 
Can be set by the Options/Show Outline menu option.

=item

C<SHOW_PROGRESS> - This is for debugging; should normally be set to `B<0>'
since it slows things down considerably.

=item

C<UNDO_AFTER_SAVE> - This permits undo after you save an image. (Note this
only works within a session, not between runs.) To switch it off, and save
a little bit of memory, set it to `B<0>'.

=back

=head2 Copyright

Copyright (c) Mark Summerfield 1999. All Rights Reserved.

Pixmaped may be used/distributed under the same terms as Perl.

=cut
