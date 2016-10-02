#!/usr/bin/python
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# SeeJuansLogs.py - read a Juan Defined Log file and filter the lines.
#

from datetime import datetime
import getopt
import re
import sys

#### Data Internals Initializations

NowO = datetime.now()
MCDY = NowO.year
MM = ( "0%d" % NowO.month if NowO.month < 10 else NowO.month )
DD = ( "0%d" % NowO.day if NowO.day < 10 else NowO.day )
Hr = ( "0%d" % NowO.hour if NowO.hour < 10 else NowO.hour )
Mi = ( "0%d" % NowO.minute if NowO.minute < 10 else NowO.minute )

#### Callable Procedures

def handleActionString(_action):
	ACTION = _action.upper()
	if ACTION != 'MOUNT' and ACTION != 'DISMOUNT':
		raise ValueError("FATAL:  Invalid Action Argument '%s' passed." % _action)
	return ACTION

def handleDateString(_date):
	if re.match(r"^\d{4}-\d{2}-\d{2}$",_date):
		return _date
#	if re.match(r"^\d{2}-\d{2}$"):
#		return "$MCDY-$_date"
#	return "$MCDY-$MM-$_date"	if $_date =~ /^\d{2}$/;
#	return "$MCDY-$MM-$DD"		if $_date =~ /^[Nn][Oo][Ww]$/;
#	return "$MCDY-$MM-$DD"		if $_date =~ /^[Tt][Oo][Dd][Aa][Yy]$/;
#	die "FATAL:  Invalid Date Argument '$_date' passed.";

def handleDeviceId(_deviceid):
	if re.match(r"^\d+,\d+,\d+,\d+$"):
		return _deviceid
	raise ValueError("FATAL:  Invalid Device ID Argument '%s' passed." % _deviceid)

def handleDevicesSymbol(_devicessymbol):
	if re.match(r"^\w+$"):
		return _devicessymbol;
	raise ValueError("FATAL:  Invalid Devices Symbol Argument '%s' passed." % _devicessymbol);

def handleIPAString(_ipa):
	if re.match(r"^\S+\.\S+\.\S+\.\S+$"):
		return _ipa;
	raise ValueError("FATAL:  Invalid IP Address Argument '%s' passed." % _ipa)

def handleTimeString(_time):
	#return _time		if $_time =~ /^\d{2}:\d{2}:\d{2}$/;
	#return _time		if $_time =~ /^\d{2}:\d{2}:?$/;
	#return "$Hr$_time"	if $_time =~ /^:\d{2}:?$/;
	#return "$Hr:$_time"	if $_time =~ /^\d{2}:?$/;
	#return "$Hr-$Mi"	if $_time =~ /^[Hh][Oo][Uu][Rr]$/;
	#return "$Hr-$Mi"	if $_time =~ /^[Nn][Oo][Ww]$/;
	raise ValueError("FATAL:  Invalid Time Argument '$_time' passed.")

def printUsage():
	print """USAGE:  ./filterlines.pl [-h] [-aA:Action] [-cC:Address] [-dD:Date] [-f:FSpec] [-iI:IPA] [-l:FSpec] [-o:FSpec] [-p:FSpec] [-sS:Devices] [-tT:Time]
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
	"""

# Initialize Section

def getswitches(argv):
	action = ''
	logfilename = 'acsss_stats.log'
	outputfile = 'STDOUT'
	devicelexicon = 'JuansDevices.tsv'
	devicesubsets = 'JuansDeviceSubsets.tsv'
	fhash = {}
	try:
		opts, args = getopt.getopt(argv,"A:a:C:c:D:d:f:hI:i:l:o:p:S:s:T:t:");
	except getopt.GetoptError:
		printUsage
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			printUsage
			sys.exit()
		elif opt in ('-A','-a'):
			filterin = (1 if opt == '-a' else 0)
			fhash['rAction'] = JuansFilter(arg,filterin)
		elif opt in ('-C','-c'):
			filterin = (1 if opt == '-c' else 0)
			fhash['rAddress'] = JuansFilter(arg,filterin)
		elif opt in ('-D','-d'):
			filterin = (1 if opt == '-d' else 0)
			fhash['rDate'] = JuansFilter(arg,filterin)
		elif opt == '-f':
			logfilename = arg
		elif opt in ('-I','-i'):
			filterin = (1 if opt == '-i' else 0)
			fhash['rIPAddress'] = JuansFilter(arg,filterin)
		elif opt == '-l':
			devicelexicon = arg
		elif opt == '-o':
			outputfile = arg
		elif opt == '-p':
			devicesubsets = arg
		elif opt in ('-S','-s'):
			fhash['DevicesList'] =  ''
		elif opt in ('-T','-t'):
			filterin = (1 if opt == '-t' else 0)
			fhash['rTime'] = JuansFilter(arg,filterin)
		else:
			# this should not be necessary; perhaps take out
			printUsage
			sys.exit(9)

if __name__ == "__main__":
	getswitches(sys.argv[1:])

	filtero = JuansFilter(fhash);

	lfo = JuansLogs(logfilename,outputfile);

	lfo.FilterSubset(filtero);

## End of Main Procedure Calls

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of SeeJuansLogs.py
