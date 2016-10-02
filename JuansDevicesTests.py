#!/usr/bin/python
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#
# JuansDevicesTests.py - read a Juan Defined Device file.
#

Verbose = False

import os

import JuansDevices
 
testdevicelist = """
MT0	0,0,1,0
MT1	0,0,1,1
MT2	0,0,1,2
MT3	0,0,1,3
MT4	0,0,1,4
MT5	0,0,1,5
MT6	0,0,1,6
MT7	0,0,1,7
"""
testdevicearray = testdevicelist.split("\n")

#JuansDevices.JuansDevices.Verbose = True

import unittest

class JuansDevicesTests(unittest.TestCase):

	def test_Count_NewFromStringArray(self):
		dlo = JuansDevices.JuansDevices.NewFromStringArray(testdevicearray) 
		self.assertEqual(len(dlo.__dict__.keys()),8)

	def test_Values_NewFromStringArray(self):
		dlo = JuansDevices.JuansDevices.NewFromStringArray(testdevicearray) 
		self.assertEqual(dlo.MT0,"0,0,1,0")
		self.assertEqual(dlo.MT4,"0,0,1,4")
		self.assertEqual(dlo.MT7,"0,0,1,7")

	def test_Count_NewFromTSV_File(self):
		fspec = "%s/TestDevices.tsv" % os.environ['PWD']
		dlo = JuansDevices.JuansDevices.NewFromTSV_File(fspec)
		self.assertEqual(len(dlo.__dict__.keys()),100)

	def test_Value_NewFromTSV_File(self):
		fspec = "%s/TestDevices.tsv" % os.environ['PWD']
		dlo = JuansDevices.JuansDevices.NewFromTSV_File(fspec)
		self.assertEqual(dlo.MT7,"0,0,1,7")

	def test_Count_NewSubset(self):
		dlo = JuansDevices.JuansDevices.NewFromStringArray(testdevicearray) 
		dlo2 = dlo.NewSubset(("MT0","MT5"))
		self.assertEqual(len(dlo2.__dict__.keys()),2)

	def test_Value_NewSubset(self):
		dlo = JuansDevices.JuansDevices.NewFromStringArray(testdevicearray) 
		dlo2 = dlo.NewSubset(("MT0","MT5"))
		self.assertEqual(dlo2.MT0,"0,0,1,0")
		self.assertEqual(dlo2.MT5,"0,0,1,5")

	def test_Count_SubsetFromTSV_File(self):
		fspec1 = "%s/TestDevices.tsv" % os.environ['PWD']
		dlo = JuansDevices.JuansDevices.NewFromTSV_File(fspec1)
		fspec2 = "%s/TestDeviceSets.tsv" % os.environ['PWD']
		sslabel = "NuclearDevices"
		dlo2 = dlo.SubsetFromTSV_File(fspec2,sslabel)
		self.assertEqual(len(dlo2.__dict__.keys()),6)

	def test_Value_SubsetFromTSV_File(self):
		fspec1 = "%s/TestDevices.tsv" % os.environ['PWD']
		dlo = JuansDevices.JuansDevices.NewFromTSV_File(fspec1)
		fspec2 = "%s/TestDeviceSets.tsv" % os.environ['PWD']
		sslabel = "NuclearDevices"
		dlo2 = dlo.SubsetFromTSV_File(fspec2,sslabel)
		self.assertEqual(dlo2.MT9,"0,0,1,9")

def main():
    unittest.main()

if __name__ == "__main__":
    main()

#2345678901234567890123456789012345678901234567890123456789012345678901234567890
# End of JuansDevicesTests.py
