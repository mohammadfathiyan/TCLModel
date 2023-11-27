proc manageTags {act args} {
	global nodeTagMap
	global eleTagMap
	global transfTagMap
	global lastNodeTag
	global lastEleTag
	global lastTransfTag
	if {$act == "-initiate"} {
		set lastNodeTag 0
		set lastEleTag 0
		set lastTransfTag 0
		if [info exists nodeTagMap] {
			unset nodeTagMap
			unset eleTagMap
			unset transfTagMap
		}
	} elseif {$act == "-newNode"} {
		if [info exists nodeTagMap($args)] {
			error "node with tag: $args already defined in map"
		}
		set nodeTagMap($args) [incr lastNodeTag]
		return $lastNodeTag
	} elseif {$act == "-getNode"} {
		if [info exists nodeTagMap($args)] {
			return $nodeTagMap($args)
		}
		error "node with tag: $args not found in map"
	} elseif {$act == "-newElement"} {
		if [info exists eleTagMap($args)] {
			error "element with tag: $args already defined in map"
		}
		set eleTagMap($args) [incr lastEleTag]
		return $lastEleTag
	} elseif {$act == "-getElement"} {
		if [info exists eleTagMap($args)] {
			return $eleTagMap($args)
		}
		error "element with tag: $args not found in map"
	} elseif {$act == "-newGeomtransf"} {
		if [info exists transfTagMap($args)] {
			error "geomTransf with tag: $args already defined in map"
		}
		set transfTagMap($args) [incr lastTransfTag]
		return $lastTransfTag
	} elseif {$act == "-getGeomtransf"} {
		if [info exists transfTagMap($args)] {
			return $transfTagMap($args)
		}
		error "geomTransf with tag: $args not found in map"
	} else {
		error "unknown act: $act in manageTags"
	}
}