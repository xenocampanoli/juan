#!/usr/bin/perl
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# JuansLogs.pm - read a Juan Defined log file.
#

use strict;
use warnings;
use 5.016;

package JuansFilter;

sub New
{
	my $_filterO = shift;

	bless $_filterO, __PACKAGE__;
}

sub checkDevices
{
	my $_this = shift;
	my $_record = shift;
	
	return 1 unless exists $_this->{DevicesIn};

	my $dl = $_this->{DevicesList};
	my @dl = values %$dl;
	foreach my $deviceid (@dl) { 
		return $_this->{DevicesIn} if $_record->{rDeviceId} eq $deviceid; 
	}
	return ! $_this->{DevicesIn};
}

sub checkEquals
{
	my $_this = shift;
	my $_record = shift;
	my $_fStr = shift;
	
	return 1 unless $_this->{$_fStr}->{dString};

	# Return true for success on filterIn true, false for filterIn false:
	my $dstr = $_this->{$_fStr}->{dString};
	return $_this->{$_fStr}->{filterIn} if $_record->{$_fStr} eq $dstr;

	# Return false for failure on filterIn true, true for filterIn false:
	return ! $_this->{$_fStr}->{filterIn};
}

sub checkMatches
{
	my $_this = shift;
	my $_record = shift;
	my $_fStr = shift;
	
	return 1 unless $_this->{$_fStr}->{dString};

	# Return true for success on filterIn true, false for filterIn false:
	my $dstr = $_this->{$_fStr}->{dString};
	return $_this->{$_fStr}->{filterIn} if $_record->{$_fStr} =~ /$dstr/;

	# Return false for failure on filterIn true, true for filterIn false:
	return ! $_this->{$_fStr}->{filterIn};
}

sub matchFilterCriteria
{
	my $_this = shift;
	my $_record = shift;

	return 0 unless	$_this->checkDevices($_record);
	return 0 unless	$_this->checkMatches($_record,"rDate");
	return 0 unless	$_this->checkMatches($_record,"rTime");
	return 0 unless	$_this->checkEquals($_record,"rAction");
	return 0 unless	$_this->checkEquals($_record,"rDeviceId");
	return 0 unless	$_this->checkEquals($_record,"rIPAddress");
	return 1;
}

package JuansLogs;

my $Verbose = 0;

#### Internal Procedures

sub blankMissing
{
	my $_record = shift;
	my $_field = shift;

	return $_record->{$_field} if defined $_record->{$_field};
	return "";
}

sub outputRecord
{
	my $_oph = shift;
	my $_record = shift;

	# Note I use quoted strings for the fields that have commas,
	# as that apparently works with excell, and appears standard.
	printf $_oph "%s,%s,%s,%s,%s,\"%s\",%s,\"%s\",%s,%s\n",
		blankMissing($_record,'rDate'),
		blankMissing($_record,'rTime'),
		blankMissing($_record,'rAction'),
		blankMissing($_record,'rNumber'),
		blankMissing($_record,'rHomeName'),
		blankMissing($_record,'rHomeId'),
		blankMissing($_record,'rDeviceName'),
		blankMissing($_record,'rDeviceId'),
		blankMissing($_record,'rNetLabel'),
		blankMissing($_record,'rIPAddress');
}

sub scanForFirstLogLine
{
	my $_line = shift;
	my $_record = {};

	if ( $_line =~ /^(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2}) (\w{0,3}MOUNT)$/ ) {
	# Note:  If not found, empty record also implies other
	# non-blank records are not of interest in this scanning,
	# as well as unexpectedly formatted records.  This may
	# need further addressing later.
		$_record->{rDate}	= $1;
		$_record->{rTime}	= $2;
		$_record->{rAction}	= $3;
	}
	return $_record;
}

sub scanForSecondLogLine
{
	my $_line = shift;
	my $_record = shift;

	if ( $_line =~ /^(\d+) (\S+) (\S+) (\S+) (\S+) (.*?) (\d+\.\d+\.\d+\.\d+)$/ ) {
		$_record->{rNumber}			= $1;
		$_record->{rHomeName}		= $2;
		$_record->{rHomeId}			= $3;
		$_record->{rDeviceName}		= $4;
		$_record->{rDeviceId}		= $5;
		$_record->{rNetLabel}		= $6;
		$_record->{rIPAddress}		= $7;
	}
	return $_record;
}

sub scanLogLines
{
	my $_line = shift;
	my $_record = shift;

	if ( $_record->{rDate} ) {
		if ( $_line =~ /^\s*$/ ) {
			print STDERR "WARN:  unexpectedly incomplete log record:\n";
			print STDERR $_record;
			print STDERR $_line;
			return $_record;
		}
		$_record = scanForSecondLogLine($_line, $_record);
	} else {
		$_record = scanForFirstLogLine($_line, $_record);
	}
	return $_record;
}

#### Interface Methods

sub New
{
	my %_jlo;

	$_jlo{iFSpec} = shift;
	$_jlo{oFSpec} = shift;

	my $ifh;
	open($ifh, '<:encoding(UTF-8)', $_jlo{iFSpec})
	  or die "Could not open file '$_jlo{iFSpec}' $!";
	$_jlo{IFH} = $ifh;

	my $ofh;
	if ( $_jlo{oFSpec} eq 'STDOUT' ) {
		$ofh = \*STDOUT;
	} else {
		open($ofh, '>', $_jlo{oFSpec})
		  or die "Could not open file '$_jlo{oFSpec}' $!";
	}
	$_jlo{OFH} = $ofh;

	bless \%_jlo, __PACKAGE__;
}

sub Close
{
	my $_jlO = shift;
	close($_jlO->{IFH});
	close($_jlO->{OFH});
}

sub Restart
{
	my $_jlO = shift;

	$_jlO->Close;
	my $ifh;
	open($ifh, '<:encoding(UTF-8)', $_jlO->{iFSpec})
	  or die "Could not open file '$_jlO->{iFSpec}' $!";
	$_jlO->{IFH} = $ifh;

	my $ofh;
	if ( $_jlO->{oFSpec} eq 'STDOUT' ) {
		$ofh = \*STDOUT;
	} else {
		open($ofh, '>', $_jlO->{oFSpec})
		  or die "Could not open file '$_jlO->{oFSpec}' $!";
	}
	$_jlO->{OFH} = $ofh;
}

sub FilterSubset
{
	my $_jlO = shift;
	my $_filterO = shift;

	my $ifh = $_jlO->{IFH};
	my $ofh = $_jlO->{OFH};
	my $line;
	my $record = {};
	
	while ( $line = <$ifh> ) {
		chomp $line;
		next unless $line =~ /\S/; # Ignores blank lines between records as
				# for now no specification deems them worthy of validation.
		$record = scanLogLines($line, $record);
		next unless exists $record->{rNumber};
		if ( $_filterO->matchFilterCriteria($record) ) {
			outputRecord($ofh,$record);
		}
		$record = {};
	}
}

1; # Artifact need of Perl class modules.  Just one more reason to use something
   #	else.
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of JuansLogs.pm
