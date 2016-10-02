#!/usr/bin/perl
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# JuansDevices.pm - read a Juan Defined Device file.
#

use strict;
use warnings;
use 5.016;

package JuansDevices;

my $Verbose = 0;

sub NewFromStringArray
{
	my %dlo;
	my $ds;
	foreach $ds (@_) {
		chomp $ds;
		my ($name,$definition) = split(/\t/,$ds);
		die "Device name '$name' not standard pattern."				unless $name =~ /^[A-Z]{2}[0-9]{1,2}$/;
		die "Device definition '$definition' not standard pattern."	unless $definition =~ /^\d,\d,\d,\d$/;
		$dlo{$name} = $definition;
	}
	bless \%dlo, __PACKAGE__;
}

sub NewFromTSV_File
{
	my $fspec = shift;
	open(my $fh, '<:encoding(UTF-8)', $fspec)
	  or die "Could not open file '$fspec' $!";

	print "Loading device dictionary from $fspec.\n" if $Verbose;
	my @dsl = <$fh>;
	my $dlo = NewFromStringArray(@dsl);
	return $dlo;
}

sub NewHashSubset
{
	my $dlo = shift;
	my $name;
	my %sshash;
	foreach $name (@_) {
		$sshash{$name} = $dlo->{$name}									if exists $dlo->{$name};
		die "FATAL:  device $name does not exist in dictionary."	unless exists $dlo->{$name};
	}
	bless \%sshash, __PACKAGE__;
}

sub SubsetFromTSV_File
{
	my $dlo = shift;
	my $fspec = shift;
	my $ssname = shift;

	open(my $fh, '<:encoding(UTF-8)', $fspec)
	  or die "Could not open file '$fspec' $!";

	print "Loading device dictionary from $fspec.\n" if $Verbose;
	my @dsl = <$fh>;
	my $ssl;	
	
	foreach $ssl (@dsl) {
		chomp $ssl;
		my ($name,$sslist) = split(/\t+/,$ssl);
		if ( $name eq $ssname ) {
			my @dlist = split(',',$sslist);
			my $sshash = NewHashSubset($dlo,@dlist);
			return $sshash;
		}
	}
	die "Subset id $ssname not found in configuration file $fspec.";
}

1; # Artifact need of Perl class modules.  Just one more reason to use something
   #	else.
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of JuansDevices.pm
