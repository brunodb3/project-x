extends Camera3D

@export var Hand: Marker3D
@export var Skeleton: Node3D
@export var VerticalPivot: Node3D
@export var HorizontalPivot: Node3D
@export var AngularAcceleration := 15.0

@export_range(40, 100) var AimingFov := 50
@export_range(40, 100) var RegularFov := 75
@export_range(0.1, 1) var FovChangeTime := 0.1

@export_range(0.0, 1.0) var MouseSensitivity := 0.1

const MOUSE_MIN := 0.02
const MOUSE_MAX := 0.1

var mouse_position := Vector2.ZERO
var mouse_position_multiplier := MOUSE_MAX
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func update_mouselook():
	mouse_position *= MouseSensitivity * mouse_position_multiplier

	var yaw := mouse_position.x
	var pitch := mouse_position.y

	HorizontalPivot.rotate_y(-yaw)

	VerticalPivot.rotate_x(-pitch)
	VerticalPivot.rotation.x = clamp(VerticalPivot.rotation.x, -PI/4, PI/4)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.relative

func _process(delta: float):
	var v_rotation = VerticalPivot.global_transform.basis.get_euler().x
	var h_rotation = HorizontalPivot.global_transform.basis.get_euler().y

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var v_direction = input.rotated(-h_rotation).normalized()
	
	if v_direction and not Input.is_action_pressed("aim") and not Hand.equippedWeapon:
		Skeleton.rotation.y = lerp_angle(Skeleton.rotation.y, atan2(-v_direction.x, -v_direction.y), delta * AngularAcceleration)

	if Hand.equippedWeapon:
		Hand.rotation.x = lerp_angle(Hand.rotation.x, v_rotation, delta * AngularAcceleration)
		Skeleton.rotation.y = lerp_angle(Skeleton.rotation.y, h_rotation, delta * AngularAcceleration)

	if Input.is_action_pressed("aim"):
		var tween = get_tree().create_tween()
		tween.tween_property(self, "fov", AimingFov, FovChangeTime)

		mouse_position_multiplier = MOUSE_MIN

		Hand.rotation.x = lerp_angle(Hand.rotation.x, v_rotation, delta * AngularAcceleration)
		Skeleton.rotation.y = lerp_angle(Skeleton.rotation.y, h_rotation, delta * AngularAcceleration)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "fov", RegularFov, FovChangeTime)

		mouse_position_multiplier = MOUSE_MAX

		Hand.rotation.x = lerp_angle(Hand.rotation.x, 0, delta * AngularAcceleration)

	update_mouselook()
