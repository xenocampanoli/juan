#!/usr/bin/perl
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# SeeJuansLogs.pl - read a Juan Defined Log file and filter the lines.
#

use strict;
use warnings;
use 5.016;

use DateTime;
use Getopt::Std;
use Readonly;

use JuansDevices;

use JuansLogs;

#### Data Internals Initializations

my $NowO = DateTime->now;
Readonly my $MCDY = $NowO->year;
Readonly my $MM = ( $NowO->month < 10 )		? "0" . $NowO->month : $NowO->month;
Readonly my $DD = ( $NowO->day < 10 )		? "0" . $NowO->day : $NowO->day;
Readonly my $Hr = ( $NowO->hour < 10 )		? "0" . $NowO->hour : $NowO->hour;
Readonly my $Mi = ( $NowO->minute < 10 )	? "0" . $NowO->minute : $NowO->minute;

#### Callable Procedures

sub handleActionString {
	my $_action = shift;
	my $ACTION = uc $_action;
	return 'MOUNT' if $ACTION eq 'MOUNT';
	return 'DISMOUNT' if $ACTION eq 'DISMOUNT';
	die "FATAL:  Invalid Action Argument '$_action' passed.";
}

sub handleDateString {
	my $_date = shift;
	return $_date				if $_date =~ /^\d{4}-\d{2}-\d{2}$/;
	return "$MCDY-$_date"		if $_date =~ /^\d{2}-\d{2}$/;
	return "$MCDY-$MM-$_date"	if $_date =~ /^\d{2}$/;
	return "$MCDY-$MM-$DD"		if $_date =~ /^[Nn][Oo][Ww]$/;
	return "$MCDY-$MM-$DD"		if $_date =~ /^[Tt][Oo][Dd][Aa][Yy]$/;
	die "FATAL:  Invalid Date Argument '$_date' passed.";
}

sub handleDeviceId {
	my $_deviceid = shift;
	return $_deviceid if $_deviceid =~ /^\d+,\d+,\d+,\d+$/;
	die "FATAL:  Invalid Device ID Argument '$_deviceid' passed.";
}

sub handleDevicesSymbol {
	my $_devicessymbol = shift;
	return $_devicessymbol if $_devicessymbol =~ /^\w+$/;
	die "FATAL:  Invalid Devices Symbol Argument '$_devicessymbol' passed.";
}

sub handleIPAString {
	my $_ipa = shift;
	return $_ipa if $_ipa =~ /^\S+\.\S+\.\S+\.\S+$/;
	die "FATAL:  Invalid IP Address Argument '$_ipa' passed.";
}

sub handleTimeString {
	my $_time = shift;
	return $_time		if $_time =~ /^\d{2}:\d{2}:\d{2}$/;
	return $_time		if $_time =~ /^\d{2}:\d{2}:?$/;
	return "$Hr$_time"	if $_time =~ /^:\d{2}:?$/;
	return "$Hr:$_time"	if $_time =~ /^\d{2}:?$/;
	return "$Hr-$Mi"	if $_time =~ /^[Hh][Oo][Uu][Rr]$/;
	return "$Hr-$Mi"	if $_time =~ /^[Nn][Oo][Ww]$/;
	die "FATAL:  Invalid Time Argument '$_time' passed.";
}

sub printUsage {
	print <<EOU;
USAGE:  ./filterlines.pl [-h] [-aA:Action] [-cC:Address] [-dD:Date] [-f:FSpec] [-iI:IPA] [-l:FSpec] [-o:FSpec] [-p:FSpec] [-sS:Devices] [-tT:Time]
  Action must be in form MOUNT or DISMOUNT.  -a means include, -A means exclude.
  Address (device address) must be in form n1,n2,n3,n4.  mnemonic coordinate is weak, but better than nothing.
  Date must be in form 13 or 09-13 or 2016-09-13.  Year,
		month or the entire date will take today as default.  -d is inclusion, -d exclusion.
  IPA is an IP Address, and this should be a regular expression like 192\\.168\\.\\d+\\.1.
		-i is inclusion, -I exclusion.
	 Devices are a named list.  A dictionary of all devices under scrutiny is read from
		JuansDevices.tsv.  A file called JuansDevicesSubsets.tsv contains subsets.  These
		can also be specified with -l:fspec to replace JuansDevices.tsv, and -p:fspec to
		replace JuansDevicesSubsets.
  TimePart must be something like 12:, or 12:12 or 12:12:12.  -t means include, -T exclude.
  -h help.
  -aA:Action string for filter.
  -cC:Device Address string for filter.
  -dD:Date string for filter.
  -f:FSpec input log filespec.
  -iI:IPA IP address for filter.
  -l:FSpec Dictionary file for filter.
  -o:FSpec output file (STDOUT if not specified).
  -p:FSpec subset file for filter.
  -sS:Devices subset id for filter.
  -tT:Time string for filter.
EOU
}

# Initialize Section

Readonly my @FilterSwitches = ('a','c','d','i','s','t');

my $action = '';
my $logfilename = 'acsss_stats.log';
my $outputfile = 'STDOUT';
my $devicelexicon = 'JuansDevices.tsv';
my $devicesubsets = 'JuansDeviceSubsets.tsv';

my %fhash = ();

if ( $#ARGV >= 0 ) {
	if ( $ARGV[0] eq "-h" ) {
		printUsage();
		exit 0;
	}
	# declare the perl command line flags/options we want to allow
	my %options=();
	getopts("A:a:C:c:D:d:f:I:i:l:o:p:S:s:T:t:", \%options);

	foreach my $switch (@FilterSwitches) {
		my $negation = uc $switch;
		if ($options{$switch} && $options{$negation}) {
			my $msg = "Cannot have a filter positive and negative of the same kind at the same time";
			die "ERROR: $msg:  {$switch,$negation}.";
		}
	}

	$logfilename = $options{f}		if $options{f};
	$devicelexicon = $options{l}	if $options{l};
	$outputfile = $options{o}		if $options{o};
	$devicesubsets = $options{p}	if $options{p};

	my $dlo = JuansDevices::NewFromTSV_File($devicelexicon);

	$fhash{rAction}{filterIn} = 0								if $options{A};
	$fhash{rAction}{dString} = handleActionString($options{A})	if $options{A};
	$fhash{rAction}{filterIn} = 1								if $options{a};
	$fhash{rAction}{dString} = handleActionString($options{a})	if $options{a};

	$fhash{rDate}{filterIn} = 0									if $options{D};
	$fhash{rDate}{dString} = handleDateString($options{D})		if $options{D};
	$fhash{rDate}{filterIn} = 1									if $options{d};
	$fhash{rDate}{dString} = handleDateString($options{d})		if $options{d};

	$fhash{rDeviceId}{filterIn} = 0								if $options{C};
	$fhash{rDeviceId}{dString} = handleDeviceId($options{C})	if $options{C};
	$fhash{rDeviceId}{filterIn} = 1								if $options{c};
	$fhash{rDeviceId}{dString} = handleDeviceId($options{c})	if $options{c};

	my $SubsetId;
	$fhash{DevicesIn} = 0										if $options{S};
	$SubsetId = handleDevicesSymbol($options{S})				if $options{S};
	$fhash{DevicesIn} = 1										if $options{s};
	$SubsetId = handleDevicesSymbol($options{s})				if $options{s};

	$fhash{DevicesList} = $dlo->SubsetFromTSV_File($devicesubsets,$SubsetId)	if $SubsetId;
	$fhash{DevicesList} = $dlo												unless $SubsetId;
	$fhash{DevicesIn} = 1													unless $SubsetId;

	$fhash{rIPAddress}{filterIn} = 0							if $options{I};
	$fhash{rIPAddress}{dString} = handleIPAString($options{I})	if $options{I};
	$fhash{rIPAddress}{filterIn} = 1							if $options{i};
	$fhash{rIPAddress}{dString} = handleIPAString($options{i})	if $options{i};

	$fhash{rTime}{filterIn} = 0									if $options{T};
	$fhash{rTime}{dString} = handleTimeString($options{T})		if $options{T};
	$fhash{rTime}{filterIn} = 1									if $options{t};
	$fhash{rTime}{dString} = handleTimeString($options{t})		if $options{t};
}


## Main Procedure Calls

my $filterO = JuansFilter::New(\%fhash);

my $lfo = JuansLogs::New($logfilename,$outputfile);

$lfo->FilterSubset($filterO);

## End of Main Procedure Calls

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SeeJuansLogs.pl
