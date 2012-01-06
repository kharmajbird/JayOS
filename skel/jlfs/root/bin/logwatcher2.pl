#!/usr/bin/perl
$ver="2.0.4";
#
#                          Firewall Builder
#
#                 Copyright (C) 2001 Vadim Kurland
#
#  Logwatcher2.pl
#  Author:  Denis Hruza					hruzaden@yaoo.com
#  Based on original logwatcher.pl by Vadim Kurland     vadim@vk.crocodile.org
#
#  Additions:
#  9/29/01
#	-  Lookups from /etc/services showing name and aliases of ports
#	-  Firewall script comment lookup for rules so you know what your looking at
#	-  Hostname lookup for source and dest
#	-  Read entire log file option --all
#  10/01/01
#	- Added code for command line options. Added help.
#	- Fixed regexp for grabbing line. Can now breakup hostname properly.
#
#  10/02/01
#	- Fixed ICMP stuff - Show type/code messages.
#	- added --show-packets for ICMP stuff.
#	- Lines to set command line options in script for ease of use
#	- It will add another -> line if SRC and DST are found in the packet data.
#	- Now detects packet data and splits up the line into $data and $packet.
#	- Rewrote $type and $code section.
#
#  11/04/01
#       - Minor bugfix   (vk)
#
#####
#
#  This is simple? script to watch iptables log and make it
#  more readable. This script drops some fields recorded by iptables
#  in the log for the sake of readability; some possibly important
#  information can be missed because of this.  In case of doubdt
#  always look in the original log!
#
#  This script expects log to be sent by syslog daemon to the file
#  /var/log/messages  which is the default setting on RedHat Linux
#  systems, however it is trivial to change this script to read any
#  other file. User running the script should have rights to read this
#  file. Script sends parsed log lines to the standard output as they
#  appear in /var/log/messages
#

use Socket; # For inet_aton function in gethostbyaddr
use Getopt::Long;

#Start config =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# Set current fwbuilder firewall script
# Example	$fw_script="/etc/rc.d/current.fw";
$fw_script="/etc/fw/Gateway1.fw";

# Log file to read from
$logfile="/var/log/messages";

# See below GetOptions to set command line options in script

#End Config =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# Read command line options, do what's needed

GetOptions(
        "logfile=s" => \$opt_logfile,
        "script=s" => \$opt_fw_script,
        "no-dns" => \$opt_dns,
        "no-services" => \$opt_services,
        "no-comments" => \$opt_comments,
        "show-packets" => \$opt_packets,
        "all" => \$opt_all,
        "simple" => \$opt_simple,
        "help" => \$help,
        "version" => \$version);

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

# uncomment IF you want to hardcode options

#opt_dns=1;		# same as --no-dns
#$opt_services=1;	# same as --no-services
#$opt_comments=1;	# same as --no-comments
#$opt_packets=1;	# same as --show-packets
#$opt_all=1;		# same as --all
#$opt_simple=1;		# same as --simple

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

start_up();

# Entire log or tail?
if ( $opt_all == 1 ) {
	open F, "cat $logfile |" || die "Could not open log file\n ERROR: $!";
	print "Checking $logfile\n";
} else {
	open F, "tail -f $logfile |" || die "Could not open log file\n ERROR: $!";
	print "Tailing $logfile\n";
}

while (<F>) {

  $datetime="";
  $hostname="";
  $rule    ="";
  $action  ="";
  $iface   ="";
  $src     ="";
  $dst     ="";
  $proto   ="";
  $s_port  ="";
  $d_port  ="";
  $type    ="";
  $code    ="";
  $data    ="";
  $packet  ="";
  $message ="";


  #original if ( $_=~/(\S+)\s+(\S+)\s+(\S+).*(RULE \S+).+-\s+(\S+).*IN=(\S+).*SRC=(\S+)\s+DST=(\S+).*PROTO=(\S+)/ ) {
   if ( $_=~/(\w+\s+\d+)\s+(\S+)\s+(\S+).*(RULE \S+).+-\s+(\S+).*IN=(\S+).*SRC=(\S+)\s+DST=(\S+).*PROTO=(\S+)/ ) {


    $datetime="$1 $2";
    $hostname= $3;
    $rule    = $4;
    $action  = $5;
    $iface   = $6;
    $src     = $7;
    $dst     = $8;
    $proto   = $9;

    #If there is packet data create $data and $packet
    if ( $_=~/^(.*)\s\[(.*)\].*$/ ) { 
	$data="$1 ";   #don't touch my space..leave it there! ;)
	$packet=$2; 
    } else {
	# Copy $_ into $data
	$data = $_
    }

    # get source and dest
    if ( $data =~ /SRC=(\S+)\s+DST=(\S+)/ ) {
      $src     = $1;
      $dst     = $2;
    }
    # Get ports
    if ( $data =~ /SPT=(\S+)\s+DPT=(\S+)/ ) {
      $s_port     = $1;
      $d_port     = $2;
    }

    # get packet source and dest
    if ( $packet =~ /SRC=(\S+)\s+DST=(\S+)/ ) {
      $p_src     = $1;
      $p_dst     = $2;
    }
    # Get packet data ports
    if ( $packet =~ /SPT=(\S+)\s+DPT=(\S+)/ ) {
      $p_s_port     = $1;
      $p_d_port     = $2;
    }


    #New section =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

    #ICMP stuff

    # PROTO is a little hard to extract. There is PROTO and there is DF PROTO

    # Here we figure out which is which. Then figure out what type/code it is and
    # then extract s_port and d_port from packet if available
    
    if ( $data =~ /\d+\sPROTO=ICMP/ || $data =~ /\sDF\sPROTO=ICMP/ ) {
	#print "\n\nDEBUG: PROTO=ICMP\n";
	$proto="ICMP";
	if ( $data =~ m/TYPE=(\d+)\s/ ) { $type = $1; }
	if ( $data =~ m/CODE=(\d+)\s/ ) { $code = $1; }
	if ( $packet =~ m/\sSPT=(\d+)\s/ ) { $s_port = "$1 (from packet)"; } else { $s_port = "N/A";}
	if ( $packet =~ m/\sDPT=(\d+)\s/ ) { $d_port = "$1 (from packet)"; } else { $d_port = "N/A";}

	$message="";$message=$type_code{$type}{$code};
    }


    # Reset

    $comment        ="";
    $proto_lc       ="";
    $s_service      ="";
    $s_port_name    ="";
    $s_port_aliases ="";
    $s_port_number  ="";
    $d_service      ="";
    $d_port_name    ="";
    $d_port_aliases ="";
    $d_port_number  ="";
    $comment        ="";
    $rule_fix       ="";
    $src_host	    ="";
    $dst_host	    ="";
    $p_src          ="";
    $p_dst          ="";
    $p_src_host     ="";
    $p_dst_host     ="";

    $proto_lc = lc "$proto";   #make proto lowercase copy

    # If we want DNS and ports, here's where it's done
    # Source -------------------------

    # Get source hostname
    if ( $opt_dns == 0 ) {
        $src_host = gethostbyaddr (inet_aton($src), AF_INET);
        $p_src_host = gethostbyaddr (inet_aton($p_src), AF_INET);
    }
    if ( $src_host eq "" ) { $src_host = "$src"; }
    if ( $p_src_host eq "" ) { $p_src_host = "$p_src"; }

    # Lookup source service/port
    if ( $opt_services == 0 ) {
    	($s_port_name,$s_port_aliases,$s_port_number) = getservbyport $s_port,$proto_lc;
    }
    if ( $s_port_name eq "" ) { 
	$s_port_name = "$s_port"; 
    } else {
	$s_port_name = "$s_port - $s_port_name"; 
    }

    # Dest ---------------------------

    # Lookup dest hostname 
    if ( $opt_dns == 0 ) {
        $dst_host = gethostbyaddr (inet_aton($dst), AF_INET);
        $p_dst_host = gethostbyaddr (inet_aton($p_dst), AF_INET);
    }
    if ( $dst_host eq "" ) { $dst_host = "$dst"; }
    if ( $p_dst_host eq "" ) { $p_dst_host = "$p_dst"; }

    # Lookup dest port/service
    if ( $opt_services == 0 ) {
        ($d_port_name,$d_port_aliases,$d_port_number,$d_protocol_name) = getservbyport $d_port,$proto_lc;
    }

    if ( $d_port_name eq "" ) { 
	$d_port_name = "$d_port"; 
    } else {
	$d_port_name = "$d_port - $d_port_name"; 
    }

    #---------------------------------	


    # Do we want the comments for the rule from the firewall config?
    if ( $opt_comments == 1 ) {
	$comment="$rule";
    } else {
        read_firewall_script();
    }

    # Print to screen
    if ( $opt_simple == 1 ) {
        print_simple();
    } else {
        print_verbose();
    }

  }
}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sub read_firewall_script {

    # Get comments from firewall script

    # Make a nice copy of "RULE" formated like firewall script comment
    $rule_fix=$rule;
    $rule_fix =~ s/RULE /#    Rule #/g;

    # Look up comment for rule in firewall script
    open(FWS,"<$fw_script") or die "Can't open $fw_script for read!\nMake sure \$fw_script is set correctly in config section of script\nERROR: $!";
	$count=""; $count_on=0;

	while ( $line=<FWS>) {
		chomp $line;
		if ( $line =~ /$rule_fix/ ) {
				$count_on=1;
		}
		
		if ( $count_on == 1 && $count < 3) {
			$comment=$line;
			$count++;
		}
		if ( $count >= 3 ) { $count_on=0; }
	}
    $comment =~ s/\#    //g;   #Clean up comment
    close(FWS);

}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sub print_verbose {

    #Verbose output to screen

    print "\n-- $comment --\n";

    if ($proto eq "ICMP" && $message ne "" ) { print "$message\n"; }

    printf "%s -> %s\n", $src_host,$dst_host;

    if ( $p_src_host && $p_dst_host ne "" ) {
	printf "%s -> %s ( from packet)\n", $p_src_host, $p_dst_host;
    }

    printf "Source Port: %s", $s_port_name;
    if ( $opt_services == 0 && $s_port_aliases ne "" ) { 
	printf " ( %s )\n", $s_port_aliases; 
	} else { print "\n"; }

    printf "  Dest Port: %s", $d_port_name;
    if ( $opt_services == 0  && $d_port_aliases ne "" ) { 
	printf " ( %s )\n", $d_port_aliases; 
    } else { print "\n"; }

    printf "%s %s %s %s %s ",$datetime,$rule,$action,$iface,$proto;

    if ($proto eq "ICMP") {
      printf "%s %s %s %s\n", $src,$dst,$type,$code;
      if ( $packet ne "" && $opt_packets == 1 ) { print "Packet:[ $packet ]\n"; }
    } else {
      printf "%s:%s %s:%s\n",$src,$s_port,$dst,$d_port;
    }
}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sub print_simple {

    #Simple (original) output to screen

    printf "%s %s %s %s %s ",$datetime,$rule,$action,$iface,$proto;

    if ($proto eq "ICMP") {
      printf "%s %s %s %s\n", $src,$dst,$type,$code;
    } else {
      printf "%s:%s %s:%s\n",$src,$s_port,$dst,$d_port; # old line
    }
}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sub start_up {

	# Check to see if it's set
	if ( $opt_comments == 0 && opt_script eq "" && $fw_script eq "" ) { print "You need to set \$fw_script in the config section of script!\n";exit; }

	# Parse command line options

	# Display help page
        if ( $help eq "1" ) {
         &help();
         exit
        }

        if ( $version eq "1" ) {
         print "logwatcher.pl Version: $ver\n";
         print "\n";
         exit
        }

	# If they request differnt sources, use them
        if ( $opt_logfile gt "" ) { $logfile = $opt_logfile; }
        if ( $opt_fw_script gt "" ) { $fw_script = $opt_fw_script; }

	# If 'simple', shut off dns and ports
	if ( $opt_simple == 1 ) { $opt_dns = 1; $opt_services=1; }
	
	# Set type_mode data
	$type_code{0}{0}="Echo Reply";
	$type_code{3}{0}="Network Unreachable";
	$type_code{3}{1}="Host Unreachable";
	$type_code{3}{2}="Protocol Unreachable";
	$type_code{3}{3}="Port Unreachable";
	$type_code{3}{4}="Fragmentation needed but no frag. bit set";
	$type_code{3}{5}="Source routing failed";
	$type_code{3}{6}="Destination network unknown";
	$type_code{3}{7}="Destination host unknown";
	$type_code{3}{8}="Source host isolated (obsolete)";
	$type_code{3}{9}="Destination network administratively prohibited";
	$type_code{3}{10}="Destination host administratively prohibited";
	$type_code{3}{11}="Network unreachable for TOS";
	$type_code{3}{12}="Host unreachable for TOS";
	$type_code{3}{13}="Communication administratively prohibited by filtering";
	$type_code{3}{14}="Host precedence violation";
	$type_code{3}{15}="Precedence cutoff in effect";
	$type_code{4}{0}="Source quelch";
	$type_code{5}{0}="Redirect for network";
	$type_code{5}{1}="Redirect for host";
	$type_code{5}{2}="Redirect for TOS and network";
	$type_code{5}{3}="Redirect for TOS and host";
	$type_code{8}{0}="Echo request";
	$type_code{9}{0}="Router advertisement";
	$type_code{10}{0}="Route sollicitation";
	$type_code{11}{0}="TTL equals 0 during transit";
	$type_code{11}{1}="TTL equals 0 during reassembly";
	$type_code{12}{0}="IP header bad (catchall error)";
	$type_code{12}{1}="Required options missing";
	$type_code{13}{0}="Timestamp request (obsolete)";
	$type_code{14}{0}="Timestamp reply (obsolete)";
	$type_code{15}{0}="Information request (obsolete)";
	$type_code{16}{0}="Information reply (obsolete)";
	$type_code{17}{0}="Address mask request";
	$type_code{18}{0}="Address mask reply";

}

# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

sub help {

	# Display help message

    print "logwatcher $ver - Firewall Builder log file parser\n";
    print "Copyright (c) 2001, Vadim Kurland\n";
    print "Authors:  Vadim Kurland, Denis Hruza\n";
    print "Requires: tail, cat\n";
    print "\n";
    print "Log file and firewall script need to be set in config section of script.\n";
    print "Alternate logfile and/or firewall script can be specified on the command line\n";
    print "\n";
    print "             Options                            Description\n";
    print " =============================== =========================================\n";
    print " All are optional:\n";
    print "   --logfile                     (str)   Optional log file to read from\n";
    print "   --script                      (str)   Optional firewall script\n";
    print "   --simple                      (bool)  Basic 1 line output\n";
    print "   --verbose                     (bool)  Display more info from log file (default)\n";
    print "   --all                         (bool)  Read entire file, do not tail\n";
    print "\n";
    print "   --no-comments                 (bool)  Do not read comments from firewall script\n";
    print "   --no-dns                      (bool)  Do not perform DNS lookups\n";
    print "   --no-services                 (bool)  Do not perfom service name lookups\n";
    print "\n";
    print "   --show-packets                (bool)  Show packets from ICMP rules\n";
    print "\n";
    print "   --help                        (bool)  Display usage information\n";
    print "   --version                     (bool)  Display version information\n";
    print "\n";
    print " Example:  ./logwatcher2.pl --logfile=\"/var/log/messages\" --all\n";
    print " =========================================================================\n";

}
