#!/usr/bin/env bats
#
# SeeJuansLogsComplexTests.bats
#

lsext=pl

@test "Test -fxcconcocted.log" {
    recordcount="$(./SeeJuansLogs.pl -fxcconcocted.log -aDISMOUNT -c0,2,1,1 -i194.48.82.1 | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.pl -fxcconcocted.log -aDISMOUNT -c0,2,1,1 -i194.48.82.2 | wc -l)"
	[ $recordcount -eq 0 ]
    recordcount="$(./SeeJuansLogs.pl -fxcconcocted.log -c0,2,1,1 -i194.48.82.1 | wc -l)"
	[ $recordcount -eq 1 ]
}

@test "Test -omycsvstuff.out" {
    ./SeeJuansLogs.pl -fxcconcocted.log -AMOUNT -D2016-08-01 -c0,2,1,1 -omycsvstuff.out
    recordcount="$(cat mycsvstuff.out | wc -l)"
	[ $recordcount -eq 4 ]
    ./SeeJuansLogs.pl -fxcconcocted.log -AMOUNT -D2016-08-01 -c0,2,1,1 -omycsvstuff.out -i198.48.82.1
    recordcount="$(cat mycsvstuff.out | wc -l)"
	[ $recordcount -eq 1 ]
}

# End of SeeJuansLogsComplexTests.bats
