package Functions;
use strict;
use File::Path;

use Network::IPv4Addr qw( :all );
use File::Path qw(make_path remove_tree);
use File::Copy;

my $APACHE_VHOSTS_DIR="/etc/apache2/vhosts.d";
my $BIND_DIR="/etc/named.d";
my $ZONE_DIR="/var/lib/named";
my $prefix = $ENV{'PREFIX'};

#TODO: fix this
my $name = "chocobo";
my $ip_addr = "10.0.0.1";
my $maskbits = "24";


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


sub gen_rev_zone_name 
{
	my $ip = shift;
	my ($a,$b,$c,$d)=split /\./, $ip;
	my $reverse_zone_name=join '.', $c, $b, $a, "in-addr", "arpa";
	return $reverse_zone_name;
}


sub get_last_octet
{
        my $ip = shift;
        my ($a,$b,$c,$d)=split /\./, $ip;
        return $d;
}



sub setup_resolv
{
	if (length $prefix)
	{
		make_path "$prefix/etc";
	}
	#back up the file if a backup is not present
	
	if (! -e "$prefix/etc/resolv.conf.bak")
	{
		copy("$prefix/etc/resolv.conf", "$prefix/etc/resolv.conf.bak");
	}
	my $filename = "$prefix/etc/resolv.conf";
	unlink ($filename);
	open(FILE, ">>$filename");
	print FILE <<"END";
nameserver 127.0.0.1;
END
	close(FILE);

}


sub create_virtual_host
{
	$name=shift;
	my $vhosts_dir="$prefix/$APACHE_VHOSTS_DIR/";
	my $vhosts_file="$vhosts_dir/$name.conf";
	make_path($vhosts_dir);
	my $wwwdir="$prefix/srv/www/$name.local";
	make_path($wwwdir);
	unlink ($vhosts_file);
	open (FILE, ">>$vhosts_file");
	print FILE <<"END";
<VirtualHost *:80>
    ServerAdmin webmaster\@$name.local
    ServerName $name.local
    DocumentRoot $wwwdir
    ErrorLog /var/log/apache2/$name.local-error_log
    CustomLog /var/log/apache2/$name.local-access_log combined
    HostnameLookups Off
    UseCanonicalName Off
    ServerSignature On
    ScriptAlias /cgi-bin/ "$wwwdir/cgi-bin/"

    <Directory "$wwwdir/cgi-bin">
        AllowOverride None
        Options +ExecCGI -Includes
        <IfModule !mod_access_compat.c>
            Require all granted
        </IfModule>
        <IfModule mod_access_compat.c>
            Order allow,deny
            Allow from all
        </IfModule>
    </Directory>


    <Directory "$wwwdir">
        Options Indexes FollowSymLinks
        AllowOverride None
        <IfModule !mod_access_compat.c>
            Require all granted
        </IfModule>
        <IfModule mod_access_compat.c>
            Order allow,deny
            Allow from all
        </IfModule>
    </Directory>

</VirtualHost>
END
	unless (-e $wwwdir or mkdir $wwwdir){
		die "Unable to create directory $wwwdir\n";
	}

	my $indexfile = "$wwwdir/index.html";
	if (! -e "$indexfile")
	{
		open(FILE, ">>$indexfile");
		print FILE <<"END";
<html>
	<head>
		 <title>Welcome to $name.local!</title>
	</head>
	<body>
		<h1>Success!  The $name.local virtual host is working!</h1>
	</body>
</html>
END
	}

}


sub setup_bind
{	
	my $name = shift;
	my $ip_addr = shift;
	my $maskbits = shift;
	my $rev_zone_name = Functions::gen_rev_zone_name($ip_addr);
	make_path("$prefix/$BIND_DIR");
	make_path("$prefix/$ZONE_DIR");
	my $filename = "$prefix/$BIND_DIR/$name";
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
	close(FILE);
	unlink("$prefix/$ZONE_DIR/for.$name.local");
	open (FILE, ">>$prefix/$ZONE_DIR/for.$name.local");
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
ns IN A $ip_addr/$maskbits	
END
	close(FILE);
	unlink("$prefix/$ZONE_DIR/rev.$name.local");
        open (FILE, ">>$prefix/$ZONE_DIR/rev.$name.local");
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
	close(FILE);
}


return 1;
