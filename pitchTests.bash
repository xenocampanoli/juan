#!/bin/bash
#
# pitchTests.bash
#

#LanguageList="Perl Python Ruby"
LanguageList="Perl"
TestScripts="SeeJuansLogsSimpleTests.bats SeeJuansLogsFileTests.bats SeeJuansLogsComplexTests.bats"

for language in $LanguageList
do
	case $language in 
		Perl)
			export lsext=pl
			#./JuansDevicesTests.pl >JuansDevicesTests.stdout 2>JuansDevicesTests.stderr
			./JuansDevicesTests.pl
			#./JuansLogsTests.pl >JuansLogsTests.stdout 2>JuansLogsTests.stderr
			./JuansLogsTests.pl
			;;
		Python)
			export lsext=py
			;;
		Ruby)
			export lsext=rb
			;;
		*)
			echo "Language $language is not supported."
			exit 1
	esac
	for ts in $TestScripts
	do
		echo 'vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv'
		echo "Running Test script $ts on $language at $(date)."
		./$ts
		echo '..................................................'
	done
done

#
# End of pitchTests.bash
