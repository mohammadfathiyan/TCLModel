
#Units: m, N, s
set g 9.81
source "$inputs(generalFolder)/lsum.tcl"
source $inputs(generalFolder)/lNorm.tcl
source $inputs(generalFolder)/manageTags.tcl
source $inputs(generalFolder)/eleCodeMap.tcl
source $inputs(generalFolder)/addNode.tcl
source $inputs(generalFolder)/releaseFromChar.tcl
source $inputs(generalFolder)/addHingeBeam.tcl
source $inputs(generalFolder)/addHingeColumn.tcl
source $inputs(generalFolder)/addFiberBeam.tcl

if ![info exists inputs(modelFolder)] {
    set inputs(modelFolder) ""
}
logCommands -comment "modelFolder: $inputs(modelFolder)\n"
source inputs.tcl
source designData.tcl
if {[info exists inputs(sharedInputsFile)] && $inputs(sharedInputsFile) != ""} {
    source $inputs(sharedInputsFile)
}
if {$inputs(matType) == "Concrete"} {
	source $inputs(generalFolder)/computeLp.tcl
}
if {$inputs(numDims) == 3} {
	source $inputs(generalFolder)/Joint3d.tcl
	source $inputs(generalFolder)/addDiaphragm.tcl
	# source $inputs(generalFolder)/crossProduct.tcl
}
model Basic -ndm $inputs(numDims)