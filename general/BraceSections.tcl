set braceMatTag [manageFEData -newMaterial braceSteel]
uniaxialMaterial Steel02 $braceMatTag [expr $inputs(fyBrace)] $inputs(Es) 0.01 18.5 .925 .15
# uniaxialMaterial Elastic $braceMatTag $e

set m -0.3
set EFrat [expr $inputs(Es)/$inputs(fyBrace)]
set fy $inputs(fyBrace)
for {set j 1} {$j <= $inputs(nFlrs)} {incr j} {
    foreach dir "X Y" nGridX "$inputs(nBaysX) [expr $inputs(nBaysX)+1]" nGridY "[expr $inputs(nBaysY)+1] $inputs(nBaysY)" {
        set code [eleCodeMap $dir-Brace]
        for {set k 1} {$k <= $nGridY} {incr k} {
            for {set i 1} {$i <= $nGridX} {incr i} {
                set pos "$j,$k,$i"
                set sec $eleData(section,$code,$pos,L)
                if {$sec == "-"} continue
                foreach mem "L R" {
                    set ID [manageFEData -newSection brace,$j,$k,$i,$mem]
                    set lBrace [manageGeomData -getBraceLength $mem $code $pos]
                    source $inputs(secFolder)/$sec.tcl
                    source $inputs(secFolder)/convertToM.tcl
                    source $inputs(generalFolder)/ComputeFatigueTube.tcl
                    set matID [manageFEData -newMaterial brace,$dir,$j,$k,$i,$mem]
                    uniaxialMaterial Fatigue $matID $braceMatTag -E0 $e0 -m $m
					Box-section $matID $ID $t3 $t2 $tf $tw $inputs(numSubdivL) $inputs(numSubdivT) [expr $G*$J]

                    set w $eleData(gussetDimI_lh,$code,$pos)
                    set l $eleData(gussetDimI_lr,$code,$pos)
                    set tp $eleData(gussetDimI_tp,$code,$pos)
                    set Lav [expr 0.67*$l]
                    set Kcal [expr 0.5*$inputs(Es)*$w*$tp**3/12./$Lav]
                    set MyGuss [expr $inputs(fyGusset)*$w*$tp**2/6.]
                    set matID [manageFEData -newMaterial gusset,$dir,$j,$k,$i,$mem]
                    uniaxialMaterial Steel02 $matID $MyGuss $Kcal 0.01
                    # uniaxialMaterial Elastic $matID [expr 0.01*$inputs(E)*$inputs(typIz)/$lBrace]
    				source $inputs(secFolder)/unsetSecProps.tcl
                }
            }
        }
    }
}