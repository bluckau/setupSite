package Functions;
use strict;

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


return 1;

