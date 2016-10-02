#!/usr/bin/env bats
#
# SeeJuansLogsSimpleTests.bats
#

@test "simple default run" {
    recordcount="$(./SeeJuansLogs.$lsext | wc -l)"
	[ $recordcount -eq 2 ]
}

@test "-h Test" {
    recordcount="$(./SeeJuansLogs.$lsext -h | wc -l)"
	[ $recordcount -gt 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -h | grep USAGE | wc -l)"
	[ $recordcount -eq 1 ]
}

@test "Test -AMOUNT" {
    recordcount="$(./SeeJuansLogs.$lsext -AMOUNT | grep ',DISMOUNT,' | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -AMOUNT | grep ',MOUNT,' | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -ADISMOUNT" {
    recordcount="$(./SeeJuansLogs.$lsext -ADISMOUNT | grep ',MOUNT,' | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -ADISMOUNT | grep ',DISMOUNT,' | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -aMOUNT" {
    recordcount="$(./SeeJuansLogs.$lsext -aMOUNT | grep ',MOUNT,' | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -aMOUNT | grep ',DISMOUNT,' | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -aDISMOUNT" {
    recordcount="$(./SeeJuansLogs.$lsext -aDISMOUNT | grep ',DISMOUNT,' | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -aDISMOUNT | grep ',MOUNT,' | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -C0,3,1,0" {
    recordcount="$(./SeeJuansLogs.$lsext -C0,3,1,0 | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -C0,3,1,0 | grep '0,3,1,0' | wc -l)"
	[ $recordcount -eq 0 ]
    recordcount="$(./SeeJuansLogs.$lsext -C0,3,1,0 | grep '0,3,1,1' | wc -l)"
	[ $recordcount -eq 1 ]
}

@test "Test -c0,3,1,0" {
    recordcount="$(./SeeJuansLogs.$lsext -c0,3,1,0 | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -c0,3,1,0 | grep ',"0,3,1,0",' | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -c0,3,1,0 | grep ',"0,3,1,1",' | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -D2016-09-13" {
    recordcount="$(./SeeJuansLogs.$lsext -D2016-09-13 | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -d2016-09-13" {
    recordcount="$(./SeeJuansLogs.$lsext -d2016-09-13 | wc -l)"
	[ $recordcount -eq 2 ]
}

@test "Test -I198.48.82.1" {
    recordcount="$(./SeeJuansLogs.$lsext -I198.48.82.1 | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -i198.48.82.1" {
    recordcount="$(./SeeJuansLogs.$lsext -i198.48.82.1 | grep ',198.48.82.1' | wc -l)"
	[ $recordcount -eq 2 ]
}

@test "Test -SDeviceSet2" {
    recordcount="$(./SeeJuansLogs.$lsext -SDeviceSet2 | wc -l)"
	[ $recordcount -eq 2 ]
}

@test "Test -sDeviceSet2" {
    recordcount="$(./SeeJuansLogs.$lsext -sDeviceSet2 | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -SDeviceSet3" {
    recordcount="$(./SeeJuansLogs.$lsext -SDeviceSet3 | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -sDeviceSet3" {
    recordcount="$(./SeeJuansLogs.$lsext -sDeviceSet3 | wc -l)"
	[ $recordcount -eq 2 ]
}

@test "Test -T04:46:52" {
    recordcount="$(./SeeJuansLogs.$lsext -T04:46:52 | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -T04:46:52 | grep '04:46:52' | wc -l)"
	[ $recordcount -eq 0 ]
}

@test "Test -t2016-09-13" {
    recordcount="$(./SeeJuansLogs.$lsext -t04:46:52 | wc -l)"
	[ $recordcount -eq 1 ]
    recordcount="$(./SeeJuansLogs.$lsext -t04:46:52 | grep '04:46:52' | wc -l)"
	[ $recordcount -eq 1 ]
}

# End of SeeJuansLogsSimpleTests.bats
