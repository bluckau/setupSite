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


sub setup_resolv()
{
	#back up the file if a backup is not present
	if (! -e "/etc/resolv.conf.bak")
	{
		copy("/etc/resolv.conf", "/etc/resolv.conf.bak");
	}
	my $filename = "/etc/resolv.conf";
	unlink ($filename);
	open(FILE, ">>$filename");
	print FILE <<"END";
nameserver 127.0.0.1;
END

}
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
	unlink($filename);
	open (FILE, ">>$filename");
	print FILE <<"END";
zone    "$name.local"   {
        type master;
        file    "for.$name.local";
};

zone   "$rev_zone_name"        {
         type master;
         notify no;
         file    "rev.$name.local";
};

END
	unlink("$ZONE_DIR/for.$name.local");
	open (FILE, ">>$ZONE_DIR/for.$name.local");
	print FILE <<"END";
;
; BIND data file for $name.local zone
;
\$TTL 604800
@               IN SOA  ns.$name.local. $name.localhost. (
1024            ; Serial
604800          ; refresh
86400           ; retry
2419200         ; expiry
604800 )        ; Negative Cache TTL
;
@ IN NS ns.$name.local.
ns IN A $net_addr	
END
	unlink("$ZONE_DIR/rev.$name.local");
        open (FILE, ">>$ZONE_DIR/rev.$name.local");
        print FILE <<"END";
;
; BIND reverse data file for rev.$name.local
;
\$TTL 604800
@               IN SOA          ns.$name.local. root.localhost. (
20              ; Serial
604800          ; refresh
86400           ; retry
2419200         ; expiry
604800 )        ; Negative Cache TTL
;
@ IN NS ns.
END
}


sub main
{
        #TODO: need to open ports instead of disabling the firewall
	Functions::disable_daemon("SuSEfirewall2_init");
	Functions::disable_daemon("SuSEfirewall2");

	#Functions::enable_daemon("apache2");
        #create_virtual_host();
        #Functions::restart_daemon("apache2");
	
	Functions::enable_daemon("named");
	setup_bind;
	setup_resolv;
	Functions::restart_daemon("named");
}

main;

