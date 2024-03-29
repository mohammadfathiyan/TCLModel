#inputs: iRec, sa, inputs(resFolder), resFilePath
#outputs: disp, failureFlag

setMaxOpenFiles 2048
set resPath $inputs(resFolder)
source $inputs(generalFolder)/interpSpectrum.tcl
source $inputs(generalFolder)/gmData.tcl
set dirFacs "1 -1"
foreach dirFac $dirFacs {
	set inputs(resFolder) $resPath/$dirFac
	source $inputs(generalFolder)/initiate.tcl
	if {$inputs(eccRatX) == 0 && $inputs(eccRatY) == 0 && $dirFac == -1} {
		continue
	}
	if {$inputs(numDims) == 3} {
		set numX [expr 2*$iRec-1]
		set numY [expr 2*$iRec]
		set inputFileX "$gmPath/$numX.AT2"
		set inputFileY "$gmPath/$numY.AT2"
		set filePathX "$gmPath/transformed/$numX.txt"
		set filePathY "$gmPath/transformed/$numY.txt"
		set outList [gmData $inputFileX "" 0]
	} else {
		set inputFileX "$gmPath/$iRec.AT2"
		set filePathX "$gmPath/transformed/$iRec.txt"
		set outList [gmData $inputFileX "" 0]
	}
	set dt [lindex $outList 0]
	set Tmax [lindex $outList 1]
	set inputs(maxFreeVibrTime) [expr 3*$Tmax]
	set TmaxCheck $Tmax
	puts "~~~~~~~~~~~~~~~~ Running rec.: $iRec, Dur,= $Tmax dir= $dirFac ~~~~~~~~~~~~~~~~"
	set resAvailable 0
	if {$inputs(checkResultAvailable)} {
		source $inputs(generalFolder)/checkResultAvailable.tcl
	}
	if {$resAvailable == 0} {
		logCommands -file $inputs(resFolder)/CmndsLog.ops
		file mkdir $inputs(resFolder)
		source $inputs(generalFolder)/buildModel.tcl
		source $inputs(generalFolder)/analyze.gravity.tcl
		if {$inputs(numDims) == 3} {
			set saUnscldX [interpSpectrum "$gmPath/spectra/$numX.txt" $T1]
			set saUnscldY [interpSpectrum "$gmPath/spectra/$numY.txt" $T1]
			set saUnscld [expr ($saUnscldX**2. + $saUnscldY**2.)**0.5]
			set fac [expr $dirFac*$g*$sa/$saUnscld]
			set seriesTagX 4
			set seriesTagY 5
			timeSeries Path $seriesTagX -dt $dt -filePath $filePathX -factor $fac  -startTime [getTime]
			timeSeries Path $seriesTagY -dt $dt -filePath $filePathY -factor $fac  -startTime [getTime]
		} else {
			set saUnscld [interpSpectrum "$gmPath/spectra/$iRec.txt" $T1]
			set fac [expr $dirFac*$g*$sa/$saUnscld]
			set seriesTagX 4
			set seriesTagY 0
			timeSeries Path $seriesTagX -dt $dt -filePath $filePathX -factor $fac  -startTime [getTime]
		}
		set deltaT 0.02
		source $inputs(generalFolder)/defineRecorders.tcl
		source $inputs(generalFolder)/analyze.gm.uniform.tcl
		if {$inputs(doFreeVibrate)} {
			set freeVibrPeriod [expr 4*$T1]
			set resTol 1.e-4
			source $inputs(generalFolder)/analyze.gm.free.tcl
		}
	}
	wipe
}
set maxDrift 0.
set maxDriftDir 0
foreach dirFac $dirFacs {
	if {$inputs(eccRatX) == 0 && $inputs(eccRatY) == 0 && $dirFac == -1} {
		continue
	}
	for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
		set inputs(resFolder) $resPath/$dirFac
		set input [open $inputs(resFolder)/envelopeDrifts/CNX$j-max.out r]
		set file [read $input]
		close $input
		set lineList [split $file \n]
		set line [lindex $lineList 2]
		set CNDr_x [lrange $line end end]
		set input [open $inputs(resFolder)/envelopeDrifts/CNY$j-max.out r]
		set file [read $input]
		close $input
		set lineList [split $file \n]
		set line [lindex $lineList 2]
		set CNDr_y [lrange $line end end]

		# set drift3d [expr max($CNDr_x, $CNDr_y)]
		set drift3d [expr ($CNDr_x**2.+$CNDr_y**2.)**0.5]
		if {$drift3d > $maxDrift} {
			set maxDrift $drift3d
			set maxDriftDir $dirFac
		}
	}
}
set disp $maxDrift

