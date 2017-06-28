#!/usr/bin/perl

#  119  2017-06-28 10:36:40 zypper install apache2-devel apache2-mod_perl
#  123  2017-06-28 10:38:14 zypper install bind bind-utils

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


sub create_virtual_host()
{
	my $filename = $FILE;
	open (FILE, ">>$filename");
print FILE <<"END";

# Ensure that Apache listens on port 
<VirtualHost *:80>
    DocumentRoot "/srv/www/$NAME"
    ServerName $NAME
    ErrorLog /var/log/apache2/$NAME-error_log
    CustomLog /var/log/apache2/$NAME-access_log combined


    # access here, or in any related virtual host.
    <Directory /srv/www/$NAME>
    Order allow,deny
    Allow from all 
    </Directory>
    
    # Other directives here
</VirtualHost>
END
}


sub setup_bind_1()
{

}



sub main()
{
	enable_daemon("apache2");
	enable_daemon("named");
	create_virtual_host();
	restart_daemon("apache2");
	#TODO: need to open ports instead of disabling the firewall 
	disable_daemon("SuSEfirewall2_init";
	disable_daemon("SuSEfirewall2";
}

main();

