#!/usr/bin/env bats
#
# SeeJuansLogsFileTests.bats
#

lsext=pl

@test "Test -facsss_stats.log" {
    recordcount="$(./SeeJuansLogs.$lsext -facsss_stats.log | wc -l)"
	[ $recordcount -eq 2 ]
    recordcount="$(./SeeJuansLogs.$lsext -fxcconcocted.log | wc -l)"
	[ $recordcount -eq 4 ]
    recordcount="$(./SeeJuansLogs.$lsext -fxcconcocted2.log | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -lTestDevices.tsv" {
    recordcount="$(./SeeJuansLogs.$lsext -lTestDevices2.tsv | wc -l)"
	[ $recordcount -eq 1 ]
}

@test "Test -omycsvstuff.out" {
    ./SeeJuansLogs.$lsext -omycsvstuff.out
    recordcount="$(cat mycsvstuff.out | wc -l)"
	[ $recordcount -eq 2 ]
}

@test "Test -pTestDevicesSets.tsv" {
    recordcount="$(./SeeJuansLogs.$lsext -pTestDevicesSets.tsv | wc -l)"
	[ $recordcount -eq 2 ]
    recordcount="$(./SeeJuansLogs.$lsext -pTestDeviceSets2.tsv -SMuck1 | wc -l)"
	[ $recordcount -eq 2 ]
    recordcount="$(./SeeJuansLogs.$lsext -pTestDeviceSets2.tsv -sMuck1 | wc -l)"
	[ $recordcount -eq 0 ]
}

# End of SeeJuansLogsFileTests.bats
