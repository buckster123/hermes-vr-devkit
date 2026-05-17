extends Node3D

@onready var xr_origin: XROrigin3D = $"../../.."
@onready var controller: XRController3D = $"../.."
@onready var teleport_ray: RayCast3D = $TeleportRay
@onready var teleport_marker: MeshInstance3D = $TeleportMarker

const TELEPORT_MAX_DISTANCE: float = 10.0
const SNAP_TURN_ANGLE: float = deg_to_rad(45.0)
const COOLDOWN: float = 0.3

var _can_teleport: bool = true
var _cooldown_timer: float = 0.0

func _ready() -> void:
	teleport_ray.target_position = Vector3(0, 0, -TELEPORT_MAX_DISTANCE)
	teleport_ray.collision_mask = 1

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
		_can_teleport = _cooldown_timer <= 0

	# Snap turn on right thumbstick X
	var thumbstick: Vector2 = controller.get_input("primary")
	if abs(thumbstick.x) > 0.5 and _can_teleport:
		var direction := sign(thumbstick.x)
		xr_origin.rotate_y(-direction * SNAP_TURN_ANGLE)
		_cooldown_timer = COOLDOWN

	# Teleport on trigger
	if controller.is_button_pressed("trigger_click"):
		_update_teleport_aim()
	else:
		if teleport_marker.visible and _can_teleport:
			_execute_teleport()
		teleport_marker.visible = false

func _update_teleport_aim() -> void:
	teleport_ray.force_raycast_update()
	if teleport_ray.is_colliding():
		var hit_point := teleport_ray.get_collision_point()
		var normal := teleport_ray.get_collision_normal()
		if normal.dot(Vector3.UP) > 0.7:
			teleport_marker.global_position = hit_point + Vector3.UP * 0.05
			teleport_marker.visible = true
			teleport_marker.material_override.albedo_color = Color.GREEN
		else:
			teleport_marker.visible = true
			teleport_marker.material_override.albedo_color = Color.RED
	else:
		teleport_marker.visible = false

func _execute_teleport() -> void:
	var target := teleport_marker.global_position
	var offset := target - xr_origin.global_position
	offset.y = 0
	xr_origin.global_position += offset
	_cooldown_timer = COOLDOWN
