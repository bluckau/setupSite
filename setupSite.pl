#!/usr/bin/perl

#  119  2017-06-28 10:36:40 zypper install apache2-devel apache2-mod_perl
#  123  2017-06-28 10:38:14 zypper install bind bind-utils

use strict;
use warnings;
use lib::Functions;

my $APACHE_VHOSTS_DIR="/etc/apache2/vhosts.d/";
my $BIND_DIR="/etc/named.d/";
my $ZONE_DIR= "/var/lib/named/";

my($name, $ip_addr, $maskbits) = @ARGV;

if (not defined $name) {
	die "Need a name";
}

if (not defined $ip_addr) {
	die "Need an IP address.";
}

if (not defined $maskbits) {
	print ( "Default to 16 bit netmask");
	$maskbits=16
}	

my $vhosts_file=$APACHE_VHOSTS_DIR.$name;
my $dns_file=$BIND_DIR.$name;
sub create_virtual_host()
{
	my $filename = $vhosts_file;
	open (FILE, ">>$filename");
print FILE <<"END";

# Ensure that Apache listens on port 
<VirtualHost *:80>
    DocumentRoot "/srv/www/$name"
    ServerName $name
    ErrorLog /var/log/apache2/$name-error_log
    CustomLog /var/log/apache2/$name-access_log combined


    # access here, or in any related virtual host.
    <Directory /srv/www/$name>
    Order allow,deny
    Allow from all 
    </Directory>
    
    # Other directives here
</VirtualHost>
END
}


sub setup_bind
{	
	my $rev_zone_name = Functions::gen_rev_zone_name($ip_addr);
	my $filename = $dns_file;
	my $net_addr = Functions::gen_network_addr ($ip_addr,$maskbits);
	#print "Net addr = " . $net_addr;
	#print "file = ".$filename;
	open (FILE, ">>$filename");
	print FILE <<"END";

allow-query { 127.0.0.1; $net_addr;};


zone    "$name.local"   {
        type master;
        file    "for.$name.local";
};

zone   "$rev_zone_name"        {
         type master;
         file    "rev.$name.local";
};
END

	open (FILE ">>$forward_zone_filename");
	print FILE <<"END";
;
; BIND data file for test.local zone
;

$TTL 1W
@               IN SOA  @   $name.local root.$name.local (
1       ; Serial
2D              ; refresh
4H              ; retry
6W              ; expiry
1W )            ; minimum

        IN      A       $ip_addr
        ;
        @       IN      NS      $name.local.
        @       IN      AAA     ::1
END
        open (FILE ">>$reverse_zone_filename");
        print FILE <<"END";
;
; BIND reverse data file for rev.$name.local
;


$TTL 1W
@               IN SOA          $name.local      root.$name.local (
	1               ; Serial
	2D              ; refresh
	4H              ; retry
	6W              ; expiry
	1W )            ; minimum
;
                IN NS           $name.local.
		142             IN PTR          $name.local.
END
}




sub main

        #TODO: need to open ports instead of disabling the firewall
	Functions::disable_daemon("SuSEfirewall2_init");
	Functions::disable_daemon("SuSEfirewall2");

	#Functions::enable_daemon("apache2");
        #create_virtual_host();
        #Functions::restart_daemon("apache2");
	
	Functions::enable_daemon("named");
	setup_bind;
	Functions::restart_daemon("named");
}

main;

