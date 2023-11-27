proc Box-section {matID secID d bf tf tw GJ} {
	set nfdw 10
	set nftw 4
	set nfbf 10
	set nftf 4
	set dw [expr $d-2*$tf]
	set y1 [expr -$d/2]
	set y2 [expr -$dw/2]
	set y3 [expr  $dw/2]
	set y4 [expr  $d/2]
  
	set z1 [expr $bf/2]
	set z2 [expr $z1-$tw]
	set z3 [expr -$z2]
	set z4 [expr -$z1]
  
	section Fiber  $secID -GJ $GJ {
   		#                     nfIJ  nfJK    yI  zI    yJ  zJ    yK  zK    yL  zL
   		patch quad  $matID  $nfbf $nftf   $y1 $z2   $y1 $z3   $y2 $z3   $y2 $z2
   		patch quad  $matID  $nftw $nfdw   $y2 $z3   $y2 $z4   $y3 $z4   $y3 $z3
   		patch quad  $matID  $nftw $nfdw   $y2 $z1   $y2 $z2   $y3 $z2   $y3 $z1
   		patch quad  $matID  $nfbf $nftf   $y3 $z2   $y3 $z3   $y4 $z3   $y4 $z2
	}
}
