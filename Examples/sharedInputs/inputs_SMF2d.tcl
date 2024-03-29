
#initiation
#_____________________________________________________
#if let to default, program will calculate these
set inputs(hasWall) 0
set inputs(hasBrace) 0

#Geometry
#_____________________________________________________
set inputs(numDims) 2
# set inputs(nFlrs) 12
set inputs(nBaysX) 3
set inputs(nBaysY) 0
set inputs(lBayX) "9.14 9.14 9.14"
set inputs(lBayY) ""
set inputs(hStory) 5.49
set inputs(hStoryBase) 4.27
set inputs(numDesnStats) 1		;#mainly for RC members
set inputs(eccRatX) 0
set inputs(eccRatY) 0

set inputs(lx) [expr 5*9.14]
set inputs(ly) [expr 5*6.09]
set inputs(planArea) [expr 0.5*$inputs(lx)*$inputs(ly)]
set inputs(planPerim) [expr $inputs(lx)+$inputs(ly)]
set inputs(cornerCrdList) "
"
# for recording corner nodes' drifts 
set inputs(cornerGrdList) "
"
#_____________________________________________________

# Mass
#_____________________________________________________
set inputs(deadRoof)  [expr $deadFac*47.88/$g*56.0] 		;#=46 (D) + 10 (superDead)
set inputs(deadFloor) [expr $deadFac*47.88/$g*61.7] 		;#64.7= 46(D)+15(superDead)+3.7(Facade) in kg/m2
set inputs(liveRoof)  [expr 1.*47.88/$g*30]
set inputs(liveFloor) [expr 1.*47.88/$g*50]
set inputs(perimBeamDead) 370.							;#kg/m of perimeter beaam
set inputs(deadMassFac) 1.05
set inputs(liveMassFac) 0.25
set inputs(selfWeightMultiplier) 1
set inputs(leaningAreaFac) 1.0
#_____________________________________________________

# Damping
#_____________________________________________________
set inputs(dampRat) 0.05
set inputs(numModes) 3
set inputs(modeI) 1
set inputs(modeJ) 2
#_____________________________________________________

# Material
#_____________________________________________________
set inputs(matType) "Steel"
# set inputs(matType) "Concrete"
if {$inputs(matType) == "Steel"} {
	#
	# set hardeningRatio 0.001		;#for fiber method
	set inputs(fyBeam) [expr 1*345.e6]
	set inputs(fyClmn) [expr 1*345.e6]
	set inputs(beamRy) 1.1
	set inputs(clmnRy) 1.1
	set inputs(isColumnA992Gr50) 1
	set inputs(isBeamA992Gr50) 1
	set inputs(nu) 0.15
	set inputs(Es) 2.e11
	set inputs(E) 2.e11
	set inputs(G) [expr $inputs(E)/2/(1.+$inputs(nu))]
	set inputs(steelDens)		7850.			;#kg/m3
	set inputs(density)		7850.			;#kg/m3
	set inputs(useRBSBeams) 1
	set inputs(usePZSpring) 0				;# =1 (panel zone modelling) is not currently supported due to efficiency concerns
} else {
	# concrete
	set inputs(fc0) 30.0e6
	set inputs(Ec)  [expr 4700.*sqrt($inputs(fc0)*1.e-6)*1.e6]
	set inputs(E) $inputs(Ec)
	set inputs(Gc) [expr $inputs(Ec)/2/(1.+$inputs(nu))]
	set inputs(G) $inputs(Gc)
	set inputs(RyConc) 1.
	set inputs(nu) 0.15
	set inputs(concDens)	2500.			;#kg/m3
	set inputs(density)		2500.			;#kg/m3
	
	#cracked inertia moment factor for elastic and lumped elements.
	#In case of lumped member, will be overwritten over hinge calculations
	set inputs(clmnCrackOverwrite) 1	;
	set inputs(beamCrackOverwrite) 1	;#for RC members
}
#_____________________________________________________

set inputs(defLeanClmn) 1		;# set to 1 when some gravity columns are excluded from the model
set inputs(leaningArea) [expr $inputs(leaningAreaFac)*$inputs(planArea)]

#Units
#_____________________________________________________
set inputs(cUnitsToN) 1.
set inputs(cUnitsToM) 1.
#_____________________________________________________
# General
set inputs(rigidZoneFac) 1.
set inputs(clmnBasePlateHeightFac) 1.	;#ratio of the column section height considered as the base plate connection offset
set inputs(clmnGeomtransfType) Linear	;#set to Linear when all story gravity force is applied on leaning column
#_____________________________________________________

# Lumped
#_____________________________________________________
set inputs(hingeType) Lignos
# set inputs(hingeType) ASCE
set inputs(SG1,eleType) Hinge
set inputs(SG1,numSeg) 1
set inputs(nFactor) 1.
set inputs(MyFac) 1.				;#to allow calibrating the model
set inputs(lbToRy) 100
# set inputs(initAxiForceFiles) {inputs(modelFolder)/gravAxiForce.txt inputs(modelFolder)/DBEAxiForce.txt}
# set inputs(initAxiForceFacts) "1. 0.2"
# set inputs(initAxiForeceEleList) ""; #will be set/used by members' proc and used by recorders proc
#_____________________________________________________


set inputs(secFolder) $inputs(generalFolder)/../sections/steel
set inputs(floorMass) [expr ($inputs(deadMassFac)*$inputs(deadFloor)+$inputs(liveMassFac)*$inputs(liveFloor))*$inputs(planArea)+$inputs(deadMassFac)*$inputs(perimBeamDead)*$inputs(planPerim)]
set inputs(roofMass) [expr ($inputs(deadMassFac)*$inputs(deadRoof)+$inputs(liveMassFac)*$inputs(liveRoof))*$inputs(planArea)]
puts "inputs(floorMass)= $inputs(floorMass)"
puts "inputs(roofMass)= $inputs(roofMass)"
puts "totalWeight = [expr 9.81*($inputs(roofMass)+($inputs(nFlrs)-1)*$inputs(floorMass))/1000.] kN"
set diaphMassList	""
for {set j $inputs(nFlrs)} {$j >= 1} {incr j -1} {
	set mass $inputs(floorMass)
	set rotMass 0
	if {$j == $inputs(nFlrs)} {
		set mass $inputs(roofMass)
	}
	lappend diaphMassList $mass
	lappend diaphMassList $rotMass
}

# - : gravity beam
# B2: SMF lateral beam
set xBeamLabels "
	B2 B2 B2
"
set yBeamLabels "
"
# - : gravity column
# C2: external SMF column
# C3: internal SMF column
# C4: external CBF column
set columnLabels "
	C2 C3 C3 C2
"
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
	set columnAngleList($i) "
		0 0 0 0
	"
}
set L1 [expr 0.25*(1.05*$inputs(deadFloor)+0.25*$inputs(liveFloor))*6.1*9.14*$g]
set L2 [expr 0.50*(1.05*$inputs(deadFloor)+0.25*$inputs(liveFloor))*6.1*9.14*$g]
for {set j 1} {$j < $inputs(nFlrs)} {incr j} {
	set pntLoadList($j) "$L1 $L2 $L2 $L1"
}

set L1 [expr 0.25*(1.05*$inputs(deadRoof)+0.25*$inputs(liveRoof))*6.1*9.14*$g]
set L2 [expr 0.50*(1.05*$inputs(deadRoof)+0.25*$inputs(liveRoof))*6.1*9.14*$g]
set j $inputs(nFlrs)
set pntLoadList($j) "$L1 $L2 $L2 $L1"

set L [expr $inputs(perimBeamDead)*$g]
for {set j 1} {$j < $inputs(nFlrs)} {incr j} {
	set beamLoadList($j) "$L $L $L $L"
}

