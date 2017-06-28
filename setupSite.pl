#!/usr/bin/perl

#  119  2017-06-28 10:36:40 zypper install apache2-devel apache2-mod_perl
#  123  2017-06-28 10:38:14 zypper install bind bind-utils

use strict;
use warnings;
use Functions;

my $APACHE_VHOSTS_DIR="/etc/apache2/vhosts.d/";
my $FILE=$APACHE_VHOSTS_DIR.Name";
my($name, $ip_address) = @ARGV;


if (not defined $name) {
	die "Need a name";
}

if (not defined $ip_address) {
	die "Need an IP address.";
}

##translate the reverse lookup zone

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


sub setup_bind_1
{
	##Dump the zones to the conf file in /etc/named.d/
	#//Had this done but lost the work!

}



sub main
{

	Functions::enable_daemon("apache2");
	Functions::enable_daemon("named");
	create_virtual_host();
	Functions::restart_daemon("apache2");
	#TODO: need to open ports instead of disabling the firewall 
	Functions::disable_daemon("SuSEfirewall2_init");
	Functions::disable_daemon("SuSEfirewall2");
}

main;

