#!/usr/bin/perl
#
#
#                          Firewall Builder
#
#                 Copyright (C) 2001 Vadim Kurland
#
#  Author:  Vadim Kurland     vadim@vk.crocodile.org
#
#####
#
#  connwatcher.pl
#
# This script processes list of connections established through the
# firewall to make it more readable.  It also restarts itself via watch(1)
# to show list of connections at regular intervals
#


$arg=$ARGV[0];

if ($arg ne "-x") {  exec "watch -n 1 $0 -x"; }


printf "Proto\tTimeout\t      Src            \t        Dst          \tStatus\n";

open F, "cat /proc/net/ip_conntrack |" || 
  die "Could not open /proc/net/ip_conntrack";

while (<F>) {

  $status="";

  if ($_=~/^tcp/ || $_=~/^udp/) {
    $_ =~ /\[(\S+)\]/;
    $status = $1;

    $_ =~ /^(\S+)/;
    $proto = $1;

    $_ =~ /\S+\s+\d+\s+(\d+)/;
    $n     = $1;

    $_ =~ /src=(\d+\.\d+\.\d+\.\d+)/;
    $src   = $1;

    $_ =~ /dst=(\d+\.\d+\.\d+\.\d+)/;
    $dst   = $1;

    $_ =~ /sport=(\d+)/;
    $sport = $1;

    $_ =~ /dport=(\d+)/;
    $dport = $1;

  }

  printf "%s\t%d\t%15s:%-5s\t%15s:%-5s\t%s\n",$proto,$n,$src,$sport,$dst,$dport,$status;

}

close F;

