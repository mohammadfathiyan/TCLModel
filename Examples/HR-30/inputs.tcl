
#initiation
#_____________________________________________________
#if let to default, program will calculate these
set inputs(hasWall) 0
set inputs(hasBrace) 1

#Geometry
#_____________________________________________________
set inputs(numDims) 3
set inputs(nFlrs) 30
set inputs(nBaysX) 6
set inputs(nBaysY) 6
set inputs(lBayX) "8. 8. 8. 8. 8. 8. 8. 8."
set inputs(lBayY) "8. 8. 8. 8. 8. 8. 8. 8."
set inputs(hStory) 4.
set inputs(hStoryBase) 4.
set inputs(numDesnStats) 1		;#mainly for RC members
set inputs(eccRatX) 0
set inputs(eccRatY) 0

set inputs(lx) [lsum $inputs(lBayX)]
set inputs(ly) [lsum $inputs(lBayY)]
set inputs(cornerCrdList) "
	0.			0.
	$inputs(lx) 0.
	$inputs(lx) $inputs(ly)
	0.			$inputs(ly)
"
# for recording corner nodes' drifts 
set inputs(cornerGrdList) "
	1							1
	[expr $inputs(nBaysX)+1]	1
	[expr $inputs(nBaysX)+1]	[expr $inputs(nBaysY)+1]
	[expr $inputs(nBaysX)+1-1]	[expr $inputs(nBaysY)+1]
	1							[expr $inputs(nBaysY)+1]
"
set inputs(planArea) [expr $inputs(lx)*$inputs(ly)]
set inputs(planPerim) [expr 2*($inputs(lx)+$inputs(ly))]
#_____________________________________________________

# Mass
#_____________________________________________________
set inputs(deadRoof)  [expr 2.e3/$g] 		
set inputs(deadFloor) [expr 2.e3/$g]
set inputs(liveRoof)  [expr 4.e3/$g]
set inputs(liveFloor) [expr 4.e3/$g]
set inputs(perimBeamDead) 370.							;#kg/m of perimeter beaam
set inputs(deadMassFac) 1.05
set inputs(liveMassFac) 0.60
set inputs(selfWeightMultiplier) 1
set inputs(leaningAreaFac) 1.0
#_____________________________________________________

# Damping
#_____________________________________________________
set inputs(dampRat) 0.02
set inputs(numModes) 3
set inputs(modeI) 1
set inputs(modeJ) 2
#_____________________________________________________

# Material
#_____________________________________________________
set inputs(matType) "Steel"
# set inputs(matType) "Concrete"
	# set hardeningRatio 0.001		;#for fiber method
	set inputs(fyBeam) [expr 1*275.e6]
	set inputs(fyClmn) [expr 1*450.e6]
	set inputs(fyBrace) 724.5e6
	set inputs(fyGusset) [expr 1*450e6]
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
	set inputs(usePZSpring) 0
#_____________________________________________________

set inputs(defLeanClmn) 1		;# set to 1 when some gravity columns are excluded from the model
set inputs(leaningArea) [expr $inputs(leaningAreaFac)*$inputs(planArea)]

#Units
#_____________________________________________________
set inputs(cUnitsToN) 1.
set inputs(cUnitsToM) 1.
#_____________________________________________________
# General
set inputs(rigidZoneFac) 0.5
set inputs(clmnBasePlateHeightFac) 1.	;#ratio of the column section height considered as the base plate connection offset
set inputs(clmnGeomtransfType) Linear	;#set to Linear when all story gravity force is applied on leaning column
#_____________________________________________________

# Lumped
#_____________________________________________________
set inputs(hingeType) Lignos
# #set inputs(hingeType) ASCE
set inputs(SG1,eleType) Hinge
set inputs(SG1,numSeg) 1
set inputs(nFactor) 1.
set inputs(MyFac) 1.				;#to allow calibrating the model
set inputs(lbToRy) 100
# set inputs(initAxiForceFiles) {inputs(modelFolder)/gravAxiForce.txt inputs(modelFolder)/DBEAxiForce.txt}
# set inputs(initAxiForceFacts) "1. 0.2"
# set inputs(initAxiForeceEleList) ""; #will be set/used by members' proc and used by recorders proc
#_____________________________________________________

#fiber
#_____________________________________________________
set inputs(numSubdivL)	6
set inputs(numSubdivT)	3
### for Hardening behavior:
	set inputs(SG2,eleType) dispBeamColumn 	;#dispBeamColumn
	set inputs(SG2,numSeg) 1
#	#set inputs(SG2,lSeg) 2.0		;#m
	set inputs(SG2,IntegStr) {Lobatto $secTag 5}

### for Softening behavior:
# set inputs(SG2,eleType) forceBeamColumn
# set inputs(SG2,numSeg) 1
# set inputs(SG2,IntegStr) {HingeRadau $secTagI $lpI $secTagJ $lpJ $secTagM}
# set inputs(SG2,IntegStr) {HingeRadauTwo $secTagI $lpI $secTagJ $lpJ $secTagM}
# set inputs(SG2,IntegStr) {Lobatto -sections 5 $secTagI $secTagM $secTagM $secTagM $secTagJ}
# set clmnLpFac 0.2

#column specific
# if ![info exists clmnShearReinfSFacs] {			
	##set if not set in specParams
	# set clmnShearReinfSFacs "1. 2. 1."
	# puts "clmnShearReinfSFacs = $clmnShearReinfSFacs"
# }

#beam specific
# set recMemSegs "1 3 4 6"

#### Braces ####
set inputs(RG,eleType) forceBeamColumn
set inputs(braceGeomType) Corotational
set inputs(braceSpanRat) [expr 1./2.]
set inputs(imperfectRat) 0.002
set inputs(RG,numSeg) 10				;#must be even
set inputs(braceInteg) {Lobatto $secTag 3}
set inputs(seeGussetSpring) 1

#_____________________________________________________

set inputs(secFolder) $inputs(generalFolder)/../sections/steel
# set inputs(lx) [lsum $inputs(lBayX)]
# set inputs(ly) [lsum $inputs(lBayY)]
# set inputs(eccRatX) 0.05
# set inputs(eccRatY) 0.05
set inputs(centerMassX) 	[expr ($inputs(eccRatX)+0.5)*$inputs(lx)]
set inputs(centerMassY) 	[expr ($inputs(eccRatY)+0.5)*$inputs(ly)]
set inputs(centerMassXRoof) 	[expr ($inputs(eccRatX)+0.5)*$inputs(lx)]
set inputs(centerMassYRoof) 	[expr ($inputs(eccRatY)+0.5)*$inputs(ly)]

set inputs(floorMass) [expr ($inputs(deadMassFac)*$inputs(deadFloor)+$inputs(liveMassFac)*$inputs(liveFloor))*$inputs(planArea)+$inputs(deadMassFac)*$inputs(perimBeamDead)*$inputs(planPerim)]
set inputs(roofMass) [expr ($inputs(deadMassFac)*$inputs(deadRoof)+$inputs(liveMassFac)*$inputs(liveRoof))*$inputs(planArea)]
set inputs(floorRotMass) [expr $inputs(floorMass)*($inputs(lx)+$inputs(ly))/6.]
set inputs(roofRotMass) [expr $inputs(roofMass)*($inputs(lx)+$inputs(ly))/6.]
puts "inputs(floorMass)= $inputs(floorMass)"
puts "inputs(roofMass)= $inputs(roofMass)"
puts "totalWeight = [expr 9.81*($inputs(roofMass)+($inputs(nFlrs)-1)*$inputs(floorMass))/1000.] kN"
set diaphMassList	""
for {set j $inputs(nFlrs)} {$j >= 1} {incr j -1} {
	set mass $inputs(floorMass)
	set rotMass $inputs(floorRotMass)
	if {$j == $inputs(nFlrs)} {
		set mass $inputs(roofMass)
		set rotMass $inputs(roofRotMass)
	}
	lappend diaphMassList $mass
	lappend diaphMassList $rotMass
}

#10: fixed about axis 1 (X), free about axis 2
# set baseFixityFlags "
# 	00  01 01 01 01 00
# 	10  00 00 00 00 10
# 	10  00 00 00 00 10
# 	10  00 00 00 00 10
# 	10  00 00 00 00 10
# 	00  01 01 01 01 00
# "
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
	set xBraceLabels($i) "
		-  -  -  -  -  -  
		-  -  -  -  -  -  
		-  -  R1 R1 -  - 
		-  -  -  -  -  -  
		-  -  R1 R1 -  - 
		-  -  -  -  -  - 
		-  -  -  -  -  -  
	"
	set yBraceLabels($i) "
		-  -  -  -  -  -  
		-  -  -  -  -  -  
		-  -  R1 R1 -  - 
		-  -  -  -  -  -  
		-  -  R1 R1 -  - 
		-  -  -  -  -  - 
		-  -  -  -  -  -  
	"
}
set xBraceLabels(15) "
	R1 R1 R1 R1 R1 R1 
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  - 
	R1 R1 R1 R1 R1 R1 
"
set xBraceLabels(30) "
	R1 R1 R1 R1 R1 R1 
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  - 
	R1 R1 R1 R1 R1 R1 
"
set yBraceLabels(15) "
	R1 R1 R1 R1 R1 R1 
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  - 
	R1 R1 R1 R1 R1 R1 
"
set yBraceLabels(30) "
	R1 R1 R1 R1 R1 R1 
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  -  
	R1 R1 R1 R1 R1 R1
	-  -  -  -  -  - 
	R1 R1 R1 R1 R1 R1 
"
set xBeamLabels "
	-  B2 B2 B2 - - 
	-  -  -  -  - -  
	-  -  -  -  - -  
	-  -  -  -  - -  
	-  -  -  -  - -  
	-  B2 B2 B2 - - 
"
set yBeamLabels "
	-  B3 -  B3 - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  -  -  -  - 
	-  B3 -  B3 - 
"
# - : gravity column
# C2: external SMF column
# C3: internal SMF column
# C4: external CBF column
set columnLabels "
	-   C2 C3 C3 C2 - 
	C4  -  -  -  -  C4
	C4  -  -  -  -  C4
	C4  -  -  -  -  C4
	C4  -  -  -  -  C4
	-   C2 C3 C3 C2 - 
"
for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
	set columnAngleList($i) "
		-  0  0  0  0  -  
		90 -  -  -  -  90  
		90 -  -  -  -  90  
		90 -  -  -  -  90  
		90 -  -  -  -  90  
		-  0  0  0  0  -  
	"
}

set L [expr (1.05*$inputs(deadFloor)+0.25*$inputs(liveFloor))*$g]
for {set j 1} {$j < $inputs(nFlrs)} {incr j} {
	set deckLoad($j) "
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
		$L $L $L $L $L
	"
}
set L [expr (1.05*$inputs(deadRoof)+0.25*$inputs(liveRoof))*$g]
set j  $inputs(nFlrs)
set deckLoad($j) "
	$L $L $L $L $L
	$L $L $L $L $L
	$L $L $L $L $L
	$L $L $L $L $L
	$L $L $L $L $L
"
##deckLoadDir == X|Y
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
	set deckLoadDir($j) "
		X X X X X
		X X X X X
		X X X X X
		X X X X X
		X X X X X
	"
}

set settingsGroup(B2) SG1
set settingsGroup(B3) SG2
set settingsGroup(C2) SG1
set settingsGroup(C3) SG1
set settingsGroup(C4) SG2
set settingsGroup(R1) RG

## beam end releases about local z axis
## R:retained	F:free
# for {set i 1} {$i <= $inputs(nFlrs)} {incr i} {
#     set xBeamFixityList($i) "
#         00 11 11 11 00
#         00 00 00 00 00
#         00 00 00 00 00
#         00 00 00 00 00
#         00 00 00 00 00
#         00 11 11 11 00
#     "
#     set yBeamReleaseList($i) "
#         00 00 00 00 00
#         00 00 00 00 00
#         00 00 00 00 00
#         00 00 00 00 00
#         00 00 00 00 00
#         00 00 00 00 00
#     "
# }
