extends Node3D

@onready var left_hand: XRNode3D = $XROrigin3D/LeftHand
@onready var right_hand: XRNode3D = $XROrigin3D/RightHand
@onready var left_visual: MeshInstance3D = $XROrigin3D/LeftHand/HandVisual
@onready var right_visual: MeshInstance3D = $XROrigin3D/RightHand/HandVisual

const PINCH_THRESHOLD: float = 0.025
const PINCH_COLOR: Color = Color(0.2, 0.8, 0.2)
const IDLE_COLOR: Color = Color(0.8, 0.2, 0.2)

var _left_pinched: bool = false
var _right_pinched: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	_left_pinched = _check_pinch(left_hand)
	_right_pinched = _check_pinch(right_hand)

	left_visual.material_override.albedo_color = PINCH_COLOR if _left_pinched else IDLE_COLOR
	right_visual.material_override.albedo_color = PINCH_COLOR if _right_pinched else IDLE_COLOR

func _check_pinch(hand_node: XRNode3D) -> bool:
	if not hand_node.is_active:
		return false

	var tracker := XRServer.get_tracker(hand_node.tracker) as XRHandTracker
	if tracker == null:
		return false

	var thumb_pos: Vector3 = tracker.get_hand_joint_position(XRHandTracker.HAND_JOINT_THUMB_TIP)
	var index_pos: Vector3 = tracker.get_hand_joint_position(XRHandTracker.HAND_JOINT_INDEX_FINGER_TIP)

	return thumb_pos.distance_to(index_pos) < PINCH_THRESHOLD
