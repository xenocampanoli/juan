#!/usr/bin/python
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# JuansDevices.py - read a Juan Defined Device file.
#

import re

class JuansDevices:

	Verbose = False

	@classmethod
	def NewFromStringArray(cls,dStrArray):
		jdo = cls()
		for ds in dStrArray:
			if re.match("^\s*$",ds):
				continue
			strline = ds.rstrip("\n")
			devicename,deviceid = strline.split("\t")
			if not re.match("^[A-Z]{2}[0-9]{1,2}$",devicename):
				raise ValueError("Device name '%s' not standard pattern." % devicename)
			if not re.match("^\d,\d,\d,\d$",deviceid):
				raise ValueError("Device definition '%s' not standard pattern." % deviceid)
			setattr(jdo,devicename,deviceid)
		return jdo

	@classmethod
	def NewFromTSV_File(cls,fSpec):
		with open(fSpec,'r') as f:
			dslines = f.readlines()
			if cls.Verbose:
				print "Loading device dictionary from %s\n" % fSpec
			jdo = cls.NewFromStringArray(dslines)
			return jdo

	def NewSubset(self,subsetNames):
		newjdo = self.__class__()
		for name in subsetNames:
			setattr(newjdo,name,getattr(self,name))
		return newjdo


	def SubsetFromTSV_File(self,fSpec,ssName):
		with open(fSpec,'r') as f:

			if self.__class__.Verbose:
				print "Loading device dictionary from %s.\n" % fSpec

			dslines = f.readlines()
		
			for ssl in dslines:
				sslstr = ssl.rstrip("\n")
				lssname,dncsv = sslstr.split("\t");
				if ssName == lssname:
					dnlist = dncsv.split(",")
					newjdo = self.NewSubset(dnlist);
					return newjdo

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of JuansDevices.py
