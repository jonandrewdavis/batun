class_name Gear

enum GearType {
	WEAPON,
	GADGET,
	SPELL,
}

var id: String
var label: String
var type: GearType
var node: Area2D
var attacks
