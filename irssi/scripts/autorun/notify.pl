##
## Put me in ~/.irssi/scripts, and then execute the following in irssi:
##
##       /load perl
##       /script load notify
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
use Net::DBus qw(:typing);
use HTML::Entities;


$VERSION = "0.2.0";
%IRSSI = (
    authors     => 'Luke Macken, Paul W. Frields',
    contact     => 'lewk@csh.rit.edu, stickster@gmail.com',
    name        => 'notify.pl',
    description => 'Use D-Bus to alert user to hilighted messages',
    license     => 'GNU General Public License',
    url         => 'http://lewk.org/log/code/irssi-notify',
);

Irssi::settings_add_str('notify', 'notify_icon', 'gtk-dialog-info');
Irssi::settings_add_str('notify', 'notify_time', '5000');

sub atoi {
    my $t;
    foreach my $d (split(//, shift())) {
	$t = $t * 10 + $d;
    }
}

sub notify {
    my ($server, $summary, $message) = @_;
    my $bus = Net::DBus->session;
    return if (!$bus);
    my $svc = $bus->get_service("org.freedesktop.Notifications");
    my $obj = $svc->get_object("/org/freedesktop/Notifications");

    # Make the message entity-safe.
    encode_entities($message);

    $obj->Notify("notify.pl",
		 0,
		 Irssi::settings_get_str('notify_icon'),
		 $summary,
		 $message,
		 ['Close', 'Close'],
		 {0, 0, 0}, 
		 Irssi::settings_get_str('notify_time'));
}
 
sub print_text_notify {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};

    return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
    notify($server, $dest->{target}, $stripped);
}

sub message_private_notify {
    my ($server, $msg, $nick, $address) = @_;

    return if (!$server);
    notify($server, "Private message from ".$nick, $msg);
}

sub dcc_request_notify {
    my ($dcc, $sendaddr) = @_;
    my $server = $dcc->{server};

    return if (!$server || !$dcc);
    notify($server, "DCC ".$dcc->{type}." request", $dcc->{nick});
}

Irssi::signal_add('print text', 'print_text_notify');
Irssi::signal_add('message private', 'message_private_notify');
Irssi::signal_add('dcc request', 'dcc_request_notify');
print "D-Bus plugin loaded.";

