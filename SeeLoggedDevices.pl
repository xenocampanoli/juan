#!/usr/bin/perl
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# SeeLoggedDevices.pl - read a Juan Defined Log file and filter the lines.
#

use strict;
use warnings;
use 5.016;

use DateTime;
use Getopt::Std;
use Readonly;

use JuansDevices;

use JuansLoggedDevices;

#### Data Internals Initializations

Readonly my $NowO = DateTime->now;
Readonly my $MCDY = $NowO->year;
Readonly my $MM = if ( $NowO->month < 10 ) : "0" . $NowO->month : $NowO->month;
Readonly my $DD = if ( $NowO->day < 10 ) : "0" . $NowO->day : $NowO->day;
Readonly my $Hr = if ( $NowO->hour < 10 ) : "0" . $NowO->hour : $NowO->hour;
Readonly my $Mi = if ( $NowO->minute < 10 ) : "0" . $NowO->minute : $NowO->minute;

my %TapeDrives = (
	MT60 => "0,0,1,0",
	MT61 => "0,0,1,7",
	MT62 => "0,0,1,8",
	MT63 => "0,1,1,1",
	MT64 => "0,1,1,4",
	MT65 => "0,1,1,9",
	MT66 => "0,0,1,1",
	MT67 => "0,0,1,13",
	MT68 => "0,0,1,5",
	MT0 => "0,1,1,7",
	MT1 => "0,1,1,10",
	MT2 => "0,1,1,11",
	MT3 => "0,1,1,15",
	MT4 => "0,1,1,13",
);

my @drivesTSM = @TapeDrives( MT60, MT61, MT62, MT63, MT64, MT65, MT66, MT67, MT68 );
my @drivesLOLO = @TapeDrives( MT0, MT1, MT2, MT3, MT4 );

#### Callable Procedures

sub printUsage {
	print "USAGE:  ./filterlines.pl [-h] [-d:Date] [-a:ActionString] [-t:TimePart]\n";
	print "  Date must be in form 13 or 09-13 or 2016-09-13.  Year,\n";
	print "		month or the entire date will take today as default.\n";
	print "  ActionString must be MOUNT or DISMOUNT.\n";
	print "  TimePart must be something like 12:, or 12:12 or 12:12:12.\n";
}

sub validateAction {
	my $_action = shift;
	my $ACTION = uc $_action;
	return MOUNT if $ACTION eq 'MOUNT';
	return DISMOUNT if $ACTION eq 'DISMOUNT';
	die "FATAL:  Invalid Action Argument '$_action' passed.";
}

sub validateDate {
	my $_date = shift;
	return $_date				if $_date =~ /^\d{4}-\d{2}-\d{2}$/;
	return "$MCDY-$_date"		if $_date =~ /^\d{2}-\d{2}$/;
	return "$MCDY-$MM-$_date"	if $_date =~ /^\d{2}$/;
	return "$MCDY-$MM-$DD"		if $_date =~ /^[Nn][Oo][Ww]$/;
	return "$MCDY-$MM-$DD"		if $_date =~ /^[Tt][Oo][Dd][Aa][Yy]$/;
	die "FATAL:  Invalid Date Argument '$_date' passed.";
}

sub validateTime {
	my $_time = shift;
	return $_time		if $_time =~ /^\d{2}:\d{2}:\d{2}$/;
	return $_time		if $_time =~ /^\d{2}:\d{2}:?$/;
	return "$Hr$_time"	if $_date =~ /^:\d{2}:?$/;
	return "$Hr:$_time"	if $_date =~ /^\d{2}:?$/;
	return "$Hr-$Mi"	if $_date =~ /^[Hh][Oo][Uu][Rr]$/;
	return "$Hr-$Mi"	if $_date =~ /^[Nn][Oo][Ww]$/;
	die "FATAL:  Invalid Date Argument '$_date' passed.";
}

# Initialize Section

#Define the tape drives. we will search for the values in quotes
#but have to report the MTxx values


#add tapedrives array if we can use this later

my $DateStr = "$MCDY-$MM-$DD"
my $TimeStr = "$Hr:"

my $action = '';
my $filename = 'acsss_stats.log';

my $num_args = $#ARGV + 1;
if ( $#ARGV >= 0) {
	if ( $ARGV[0] eq "-h" ) {
		printUsage();
		exit 0;
	}
	# declare the perl command line flags/options we want to allow
	my %options=();
	getopts("a:d:t:", \%options);

	$action = validateActionStr($options{a}) if $options{a}
	$datestr = validateDateStr($options{d}) if $options{d}
	$timestr = validateTimeStr($options{t}) if $options{t}
}

open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";

## Main activity Section

# NOTE:  I'm going to presume your log files may be very long, so that
# it would not be a good plan to load the entire thing, but to read line
# by line as your initial file did.

my $rdate = "";
my $rtime = "";
my $raction = "";

my $rno = "";
my $rl1 = "";
my $rdn1 = "";
my $rl2 = "";
my $rdn2 = "";
my $rrl = "";
my $ripaddr = "";

while (my $row = <$fh> ) {
	if ( $row =~ /^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) (\w{0,3}MOUNT/) ) {
		if ( $ActionStr ) { next unless $row =~ / $ActionStr/; }
		if ( $DateStr ) { next unless $row =~ /^$DateStr /; }
		if ( $TimeStr ) { next unless $row =~ / $TimeStr /; }
		$rdate = $1;
		$rtime = $2;
		$raction = $3;
	}
	next unless $rdate;
	if ( $row =~ /^(\d+) (\S+) (\S+) (\S+) (\S+) (.*?) (\d+\.\d+\.\d+\.\d+)/ ) {
		$rno=$1;
		$rl1=$2;
		$rdn1=$3;
		$rl2=$4;
		$rdn2=$5;
		$rrl=$6;
		$ripaddr=$7;
		print "$rdate,$rtime,$raction,$rno,$rl1,$rdn1,$rl2,$rdn2,$rrl,$ripaddr\n"
		$rdate = "";
	}
	print STDERR "WARN:  record with $rdate, $rtime, $raction had blank second row." if $row =~ /^\s*$/;
	print STDERR "WARN:  record with $rdate, $rtime, $raction had invalid second row:\n$row" if $row =~ /\S+/;
}

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SeeLoggedDevices.pl
