#!/usr/bin/perl


use strict;
use warnings;
my $APACHE_VHOSTS_DIR="/etc/apache2/vhosts.d/";
my $NAME="chocobo";
my $FILE=$APACHE_VHOSTS_DIR."chocobo";
my $ADDRESS="127.0.0.1";

sub enable_daemon
{
	my $daemon = shift;
	system("/usr/bin/systemctl", "enable",$daemon);
	system("/usr/bin/systemctl", "start",$daemon);
}

sub disable_daemon
{
	my $daemon = shift;
	system("/usr/bin/systemctl", "disable",$daemon);
	system("/usr/bin/systemctl", "stop",$daemon);
}


sub restart_daemon
{

	my $daemon = shift;
	system("/usr/bin/systemctl", "restart",$daemon);

}



