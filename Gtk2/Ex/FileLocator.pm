package Gtk2::Ex::FileLocator;
use strict;
use warnings;

use Gtk2;
use Glib qw(TRUE FALSE);

use Gtk2::Ex::FileLocator::DropPocket;
use Gtk2::Ex::FileLocator::PathBar;
use Gtk2::Ex::FileLocator::PathnameField;
use Gtk2::Ex::FileLocator::RecycleButton;

use Glib::Object::Subclass
  Gtk2::VBox::,
  properties => [
	Glib::ParamSpec->boolean(
		'stdout', 'stdout', 'Output filename to stdout',
		FALSE, [qw/readable writable/]
	),
  ],
  signals => {
	current_folder_changed => {
		param_types => [qw(Glib::Scalar)],
	},
	file_activated => {
		param_types => [qw(Glib::Scalar)],
	},
  },
  ;

sub INIT_INSTANCE {
	my ($this) = @_;

	$this->{filename} = "";

	my $hbox = new Gtk2::HBox;
	$hbox->set_spacing(2);

	$this->{dropPocket} = new Gtk2::Ex::FileLocator::DropPocket;
	$hbox->pack_start( $this->{dropPocket}, FALSE, FALSE, 0 );

	my $vbox = new Gtk2::VBox;
	$vbox->set_spacing(0);

	$this->{pathBar} = new Gtk2::Ex::FileLocator::PathBar;
	$vbox->pack_start( $this->{pathBar}, TRUE, TRUE, 0 );

	$this->{pathnameField} = new Gtk2::Ex::FileLocator::PathnameField;
	$vbox->pack_start( $this->{pathnameField}, FALSE, FALSE, 0 );

	$hbox->pack_start( $vbox, TRUE, TRUE, 0 );

	$this->{recycleButton} = new Gtk2::Ex::FileLocator::RecycleButton;
	$hbox->pack_start( $this->{recycleButton}, FALSE, FALSE, 0 );

	$this->pack_start( $hbox, TRUE, TRUE, 0 );

	$this->{dropPocket}->signal_connect( 'file-activated'    => \&on_file_activated, $this );
	$this->{pathBar}->signal_connect( 'file-activated'       => \&on_file_activated, $this );
	$this->{pathnameField}->signal_connect( 'file-activated' => \&on_file_activated, $this );
	$this->{recycleButton}->signal_connect( 'file-activated' => \&on_file_activated, $this );

	$this->{pathnameField}->signal_connect( 'scroll-offset-changed' => sub { $this->{pathBar}->set_scroll_offset( $_[1] ) } );
	$this->{pathnameField}->signal_connect_after( 'size-request' => sub { $this->{pathBar}->configure_buttons } );
}

sub on_file_activated {
	my ( $widget, $this ) = @_;

	my $uri = $widget->get_uri;
	printf "**** %s\n", $uri;
	
	$this->{dropPocket}->set_uri($uri)    unless $widget == $this->{dropPocket};
	#$this->{pathBar}->set_uri($uri)       unless $widget == $this->{pathBar};
	#$this->{pathnameField}->set_uri($uri) unless $widget == $this->{pathnameField};
	#$this->{recycleButton}->set_uri($uri) unless $widget == $this->{recycleButton};

	#printf "%s\n", $filename if $this->get('stdout');
}

sub set_filename {
	my ( $this, $filename ) = @_;

	$this->{filename} = $filename || "";

	$this->{dropPocket}->set_filename($filename);
	$this->{pathBar}->set_filename($filename);
	$this->{pathnameField}->set_filename($filename);
	$this->{recycleButton}->set_filename($filename);
	return;
}

sub get_filename {
	my ($this) = @_;
	return $this->{filename};
}

sub get_droppocket {
	my ($this) = @_;
	return $this->{dropPocket};
}

sub get_pathbar {
	my ($this) = @_;
	return $this->{pathBar};
}

sub get_pathnamefield {
	my ($this) = @_;
	return $this->{pathnameField};
}

sub get_recyclebutton {
	my ($this) = @_;
	return $this->{recycleButton};
}

1;
__END__

=head1 NAME

Gtk2::Ex::FileLocator Widget - find an icon on the system

=head1 SYNOPSIS

	use Gtk2;
	use Glib qw(TRUE FALSE);
	use Gtk2::Ex::FileLocator;
	
	Gtk2->init;
	$this = new Gtk2::Window;

	$this->set_title('File QuickFind');
	$this->set_position('GTK_WIN_POS_MOUSE');
	$this->set_default_size( 300, -1 );
	#$this->set_size_request( 300, -1 );

	$this->{fileLocator} = new Gtk2::Ex::FileLocator;
	$this->{fileLocator}->show;

	$this->add( $this->{fileLocator} );

	$this->signal_connect( delete_event => sub { Gtk2->main_quit } );
	$this->show_all;
	Gtk2->main;

=head1 DESCRIPTION

The File QuickFind dialog allows the user to retrieve the icon for a
particular file, or conversely to obtain the fully-qualified filename for
an icon.

The File QuickFind dialog presents a small window containing a drop
pocket and a text field.  If the user drags an icon from the 
Desktop into the drop pocket, the text field will show the
icon's location on the system with its full path name.  If the user types
a name in the text field, the dialog will search for an icon matching
that name in the user's home directory, then, if no matching icon is
found, in the directories specified in the user's path environment
variable.  Icons that appear in the drop pocket can be dragged out onto
the Desktop or manipulated in place (ex., double-clicked).

=head1 SEE ALSO

http://techpubs.sgi.com/library/tpl/cgi-bin/getdoc.cgi/srch21@pathbar%20pathnamefield/0650/bks/SGI_EndUser/books/Desktop_UG/sgi_html/ch13.html#LE20204-PARENT

=head1 AUTHOR

Holger Seelig <holger.seelig@yahoo.de>

=cut
