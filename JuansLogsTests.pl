#!/usr/bin/perl
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# JuansLogsTests.pl
#

use strict;
use warnings;
use 5.016;

use Test::Simple tests => 47;
 
use JuansDevices;  # What you're testing.
use JuansLogs;  # What you're testing.
 
# #### Test JuansFilter::New

my $jfo = JuansFilter::New({},[],0);
ok( $jfo,"Object created by JuanFilter::New with empty fields.");

# #### Test JuansFilter::checkEquals

my $recordH0 = { 'rAction' => 'DISMOUNT' };
my $filterO0a = JuansFilter::New({ 'rAction' => { 'dString' => 'MOUNT', 'filterIn' => 1 } });

my $bb0a = $filterO0a->checkEquals($recordH0,'rAction');
ok( !$bb0a,"checkEquals generated false for recordH0 and filter object 0a." );

my $filterO0b = JuansFilter::New({ 'rAction' => { 'dString' => 'DISMOUNT', 'filterIn' => 1 } });

my $bb0b = $filterO0b->checkEquals($recordH0,'rAction');
ok( $bb0b,"checkEquals generated false for recordH0 and filter object 0b." );

# #### Test JuansFilter::checkMatches

my $recordH1 = { 'rDate' => '2016-09-21' };
my $filterO1 = JuansFilter::New({ 'rDate' => { 'dString' => '2016-09-21', 'filterIn' => 1 } });

my $bb1 = $filterO1->checkMatches($recordH1,'rDate');

ok( $bb1,"checkMatches generated true for recordH1 and filter object 1." );

my $filterO2 = JuansFilter::New({ 'rDate' => { 'dString' => '2016-09-21', 'filterIn' => 0 } });

my $bb2 = $filterO2->checkMatches($recordH1,'rDate');

ok( !$bb2,"checkMatches generated true for recordH1 and filter object 2." );

my $recordH2 = { 'rDate' => '2016-09-22' };

my $bb3 = $filterO1->checkMatches($recordH2,'rDate');

ok( !$bb3,"checkMatches generated true for recordH2 and filter object 1." );

my $bb4 = $filterO2->checkMatches($recordH2,'rDate');

ok( $bb4,"checkMatches generated true for recordH2 and filter object 2." );

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

my $deviceslistO = JuansDevices::NewFromStringArray(@sa);

my $filterO3 = JuansFilter::New({},$deviceslistO,1);

$recordH1->{rDeviceId} = '0,0,1,0';

my $bb5 = $filterO3->checkDevices($recordH1);

ok( $bb5,"checkDevices generated true for recordH1 with device id '0,0,1,0' added, and filter object 3." );

my $filterO4 = JuansFilter::New({ DevicesList => $deviceslistO, DevicesIn => 0 });

my $bb6 = $filterO4->checkDevices($recordH1);

ok( !$bb6,"checkDevices generated false for recordH1 with device id '0,0,1,0' added, and filter object 4." );

# #### Test JuansFilter::matchFilterCriteria

my $bb7 = $filterO1->matchFilterCriteria($recordH1);
ok( $bb7,"matchFilterCriteria generated true for recordH1 with device id '0,0,1,0' added, and filter object 1." );

my $bb8 = $filterO2->matchFilterCriteria($recordH1);
ok( !$bb8,"matchFilterCriteria generated false for recordH1 with device id '0,0,1,0' added, and filter object 1." );

my $bb9 = $filterO3->matchFilterCriteria($recordH1);
ok( $bb9,"matchFilterCriteria generated true for recordH1 with device id '0,0,1,0' added, and filter object 1." );

my $bb10 = $filterO4->matchFilterCriteria($recordH1);
ok( !$bb10,"matchFilterCriteria generated false for recordH1 with device id '0,0,1,0' added, and filter object 1." );

# #### Test JuansLogs::blankMissing

my $bb11 = JuansLogs::blankMissing({Something => 'something'},'Something');
ok( $bb11 eq 'something' ,"blankMissing generated string 'something'.");

my $bb12 = JuansLogs::blankMissing({Something => undef}, 'Something');
ok( $bb12 eq '',"blankMissing generated empty string ''.");

my $bb13 = JuansLogs::blankMissing({},'Something');
ok( $bb13 eq '',"blankMissing generated empty string ''.");

# #### Test JuansLogs::outputRecord

my $fofspec = "/tmp/tof.lst";

open(my $tfh,">",$fofspec) || die "Could not open $fofspec.";
JuansLogs::outputRecord($tfh,$recordH1);
close($tfh);

open($tfh,"<",$fofspec) || die "Could not open $fofspec for read.";
my $bigstr = <$tfh>;
close($tfh); 
chomp $bigstr;
my $csvstr = '2016-09-21,,,,,"",,"0,0,1,0",,';
ok( $bigstr eq $csvstr,"JuansLogs::outputRecord generated csv '$csvstr'.");

$recordH1->{rTime} = '04:46:52';
$recordH1->{rAction} = 'MOUNT';
$recordH1->{rNumber} = '101240';
$recordH1->{rHomeName} = 'HOME';
$recordH1->{rHomeId} = '0,1,2,3,4';
$recordH1->{rDeviceName} = 'MTA99';
$recordH1->{rDeviceId} = '0,1,2,3';
$recordH1->{rNetLabel} = 'Client Host Id';
$recordH1->{rIPAddress} = '192.168.0.57';

open($tfh,">",$fofspec) || die "Could not open $fofspec.";
JuansLogs::outputRecord($tfh,$recordH1);
close($tfh);

open($tfh,"<",$fofspec) || die "Could not open $fofspec for read.";
$bigstr = <$tfh>;
close($tfh); 
chomp $bigstr;
$csvstr = '2016-09-21,04:46:52,MOUNT,101240,HOME,"0,1,2,3,4",MTA99,"0,1,2,3",Client Host Id,192.168.0.57';
ok( $bigstr eq $csvstr,"JuansLogs::outputRecord generated csv '$csvstr'.");

unlink($fofspec);

# #### Test JuansLogs::scanForFirstLogLine

my $lc1 = <<EOLC1;
2018-01-01 01:01:01 MOUNT
123456 Home 0,1,2,3,4 Drive 0,0,1,0 Client Host Id 192.168.0.1

EOLC1
my @lc1 = split("\n",$lc1);

my $rh1 = {};
$rh1 = JuansLogs::scanForFirstLogLine($lc1[0],$rh1);

ok( $rh1->{rDate} eq '2018-01-01',"JuansLogs::scanForFirstLogLine.");
ok( $rh1->{rTime} eq '01:01:01',"JuansLogs::scanForFirstLogLine.");
ok( $rh1->{rAction} eq 'MOUNT',"JuansLogs::scanForFirstLogLine.");

# #### Test JuansLogs::scanForSecondLogLine

$rh1 = JuansLogs::scanForSecondLogLine($lc1[1],$rh1);

ok( $rh1->{rNumber} eq '123456',"JuansLogs::scanForSecondLogLine.");
ok( $rh1->{rHomeName} eq 'Home',"JuansLogs::scanForSecondLogLine.");
ok( $rh1->{rHomeId} eq '0,1,2,3,4',"JuansLogs::scanForSecondLogLine.");
ok( $rh1->{rDeviceName} eq 'Drive',"JuansLogs::scanForSecondLogLine.");
ok( $rh1->{rDeviceId} eq '0,0,1,0',"JuansLogs::scanForSecondLogLine.");
ok( $rh1->{rNetLabel} eq 'Client Host Id',"JuansLogs::scanForSecondLogLine.");
ok( $rh1->{rIPAddress} eq '192.168.0.1',"JuansLogs::scanForSecondLogLine.");

# #### Test JuansLogs::scanLogLines

my $rh2;
$rh2 = JuansLogs::scanLogLines($lc1[0],$rh2);
$rh2 = JuansLogs::scanLogLines($lc1[1],$rh2);
ok( $rh2->{rDate} eq '2018-01-01',"JuansLogs::scanLogLines.");
ok( $rh2->{rTime} eq '01:01:01',"JuansLogs::scanLogLines.");
ok( $rh2->{rAction} eq 'MOUNT',"JuansLogs::scanLogLines.");
ok( $rh2->{rNumber} eq '123456',"JuansLogs::scanLogLines.");
ok( $rh2->{rHomeName} eq 'Home',"JuansLogs::scanLogLines.");
ok( $rh2->{rHomeId} eq '0,1,2,3,4',"JuansLogs::scanLogLines.");
ok( $rh2->{rDeviceName} eq 'Drive',"JuansLogs::scanLogLines.");
ok( $rh2->{rDeviceId} eq '0,0,1,0',"JuansLogs::scanLogLines.");
ok( $rh2->{rNetLabel} eq 'Client Host Id',"JuansLogs::scanLogLines.");
ok( $rh2->{rIPAddress} eq '192.168.0.1',"JuansLogs::scanLogLines.");

# #### Test JuansLogs::New

my $ifspec = 'acsss_stats.log';

my $jlo = JuansLogs::New($ifspec,$fofspec);
ok( $jlo,"JuansLogs::New makes nonblank scalar object.");
ok( $jlo->{iFSpec} eq $ifspec,"JuansLogs::New makes iFSpec attribute.");
ok( $jlo->{oFSpec} eq $fofspec,"JuansLogs::New makes oFSpec attribute.");
ok( $jlo->{IFH},"JuansLogs::New makes IFH attribute.");
ok( $jlo->{OFH},"JuansLogs::New makes OFH attribute.");

# #### Test JuansLogs::FilterSubset
# #### Test JuansLogs::Close

my $filterO5 = JuansFilter::New({ 'rDate' => { 'dString' => '2016-09-13', 'filterIn' => 1 } });

$jlo->FilterSubset($filterO5);
$jlo->Close;

open($tfh,"<",$fofspec) || die "Could not open $fofspec for read.";
local $/;
$bigstr = <$tfh>;
ok($bigstr,"JuansLogs::FilterSubset generated a nonblank file.");
my @biga = split("\n",$bigstr);
close($tfh); 
$csvstr = '2016-09-13,04:46:52,MOUNT,101240,Home,"0,3,33,4,1",Drive,"0,3,1,0",Client Host Id,198.48.82.1';
ok( $biga[0] eq $csvstr,"JuansLogs::outputRecord generated csv '$csvstr'.");
ok( @biga == 2,"JuansLogs::outputRecord generated two csv records.");

unlink($fofspec);

# #### Test JuansLogs::FilterSubset
# #### Test JuansLogs::Restart

my $filterO6 = JuansFilter::New({ 'rDate' => { 'dString' => '2016-09-13', 'filterIn' => 0 } });

$jlo->Restart;

$jlo->FilterSubset($filterO6);
$jlo->Close;

open($tfh,"<",$fofspec) || die "Could not open $fofspec for read.";
local $/;
$bigstr = <$tfh>;
ok(!$bigstr,"JuansLogs::FilterSubset generated a blank file.");
@biga = split("\n",$bigstr);
close($tfh); 

unlink($fofspec);

# #### Test JuansLogs::FilterSubset
# #### Test JuansLogs::Restart
#
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of JuansLogsTests.pl
