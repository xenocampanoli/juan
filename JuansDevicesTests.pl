#!/usr/bin/perl
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# JuansDevicesTests.pl - read a Juan Defined Device file.
#

use strict;
use warnings;
use 5.016;

use Test::Simple tests => 9;
 
use JuansDevices;  # What you're testing.
 
# #### Test JuansDevices::NewFromStringArray:

my $sa = <<EOSA;
MT0	0,0,1,0
MT1	0,0,1,1
MT2	0,0,1,2
MT3	0,0,1,3
MT4	0,0,1,4
MT5	0,0,1,5
MT6	0,0,1,6
MT7	0,0,1,7
EOSA
my @sa = split("\n",$sa);

# #### Test JuansDevices::NewFromStringArray

my $dlo1 = JuansDevices::NewFromStringArray(@sa);

ok( $dlo1->{MT0} eq '0,0,1,0','NewFromStringArray(@sa) got first element of array.' );
ok( $dlo1->{MT4} eq '0,0,1,4','NewFromStringArray(@sa) got middle element of array.' );
ok( $dlo1->{MT7} eq '0,0,1,7','NewFromStringArray(@sa) got last element of array.' );

my $kc1 = keys %$dlo1;

ok( $kc1 == 8,'NewFromStringArray got 8 devices in the string array.' );

# #### Test JuansDevices::NewFromTSV_File

my $f1 = "$ENV{PWD}/TestDevices.tsv";
my $dlo2 = JuansDevices::NewFromTSV_File($f1);
ok( $dlo2->{MT7} eq '0,0,1,7',"NewFromTSV_FILE got line 8 from file $f1.");

my $kc2 = keys %$dlo2;
ok( $kc2 == 100,'NewFromTSV_FILE got 100 devices from the definition file.' );

# #### Test JuansDevices::NewHashSubset

my $dlo3 = JuansDevices::NewHashSubset($dlo1,("MT0","MT5"));
my $kc3 = keys %$dlo3;
ok( $kc3 == 2,'NewHashSubset() got 2 devices.' );

# #### Test JuansDevices::SubsetFromTSV_File

my $sslabel = "NuclearDevices";
my $dlo4 = $dlo2->SubsetFromTSV_File("$ENV{PWD}/TestDeviceSets.tsv",$sslabel);
my $kc4 = keys %$dlo4;
ok( $kc4 == 6,'SubsetFromTSV_File got 2 devices.' );
ok( $dlo2->{MT9} eq '0,0,1,9',"NewFromTSV_FILE got line 10 from file $f1.");

#
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of JuansDevicesTests.pl
