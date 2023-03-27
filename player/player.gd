class_name Player
extends CharacterBody3D

@export var HPivot: Node3D
@export var VPivot: Node3D
@export var Hand: Marker3D
@export var Skeleton: Node3D
@export var Model: CharacterModel
@export var ThirdPersonCam: Camera3D

@export var Jump := 4.5
@export var RunSpeed := 5.0
@export var AimSpeed := 2.0
@export var WalkSpeed := 2.0
@export var Acceleration := 5.0
@export var AngularAcceleration := 15.0

@export_range(40, 100) var AimingFov := 50
@export_range(40, 100) var RegularFov := 75
@export_range(0.1, 1) var FovChangeTime := 0.1

@export_range(0.1, 1.0) var MouseSensitivity := 0.1
@export_range(0.02, 0.1) var MouseAimSensitivity := 0.02

@onready var Rifle := preload("res://weapons/rifle/rifle.tscn")
@onready var Pistol := preload("res://weapons/pistol/pistol.tscn")

enum WEAPONS {
	PISTOL,
	RIFLE
}

var equippedWeapon: Weapon
var mouse_position := Vector2.ZERO
var mouse_multiplier := MouseSensitivity
var selectedWeapon: WEAPONS = WEAPONS.PISTOL
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func handle_movement(delta: float) -> void:
	var speed: float

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = Jump

	if Input.is_action_pressed("aim"):
		speed = AimSpeed
	elif Input.is_action_pressed("run"):
		speed = RunSpeed
	else:
		speed = WalkSpeed

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var h_rotation = HPivot.global_transform.basis.get_euler().y
	var direction = input.rotated(-h_rotation).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.y, 0, speed)

	move_and_slide()
	update_model_animations(input)

func update_model_animations(input: Vector2) -> void:
	var rounded_velocity = snapped(velocity.length(), 0.1)

	if rounded_velocity == WalkSpeed:
		Model.set_movement_animation(Model.MOVEMENT.WALK)
	
	if rounded_velocity == RunSpeed:
		Model.set_movement_animation(Model.MOVEMENT.RUN)

	if rounded_velocity == 0:
		Model.set_movement_animation(Model.MOVEMENT.IDLE)
		Model.strafe_direction = Vector3.ZERO
	else:
		Model.strafe_direction = Vector3(input.x, 0, input.y)

	Model.set_strafing(Input.is_action_pressed("aim"))

func handle_rotation(delta: float) -> void:
	var v_rotation = VPivot.global_transform.basis.get_euler().x
	var h_rotation = HPivot.global_transform.basis.get_euler().y

	var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var v_direction = input.rotated(-h_rotation).normalized()

	if v_direction and not Input.is_action_pressed("aim") and not equippedWeapon:
		Skeleton.rotation.y = lerp_angle(Skeleton.rotation.y, atan2(-v_direction.x, -v_direction.y), delta * AngularAcceleration)

	if equippedWeapon:
		Hand.rotation.x = lerp_angle(Hand.rotation.x, v_rotation, delta * AngularAcceleration)
		Skeleton.rotation.y = lerp_angle(Skeleton.rotation.y, h_rotation, delta * AngularAcceleration)

	if Input.is_action_pressed("aim"):
		var tween = get_tree().create_tween()
		tween.tween_property(ThirdPersonCam, "fov", AimingFov, FovChangeTime)

		mouse_multiplier = MouseAimSensitivity

		Hand.rotation.x = lerp_angle(Hand.rotation.x, v_rotation, delta * AngularAcceleration)
		Skeleton.rotation.y = lerp_angle(Skeleton.rotation.y, h_rotation, delta * AngularAcceleration)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(ThirdPersonCam, "fov", RegularFov, FovChangeTime)

		mouse_multiplier = MouseSensitivity

		Hand.rotation.x = lerp_angle(Hand.rotation.x, 0, delta * AngularAcceleration)

	mouse_position *= MouseSensitivity * mouse_multiplier

	var yaw := mouse_position.x
	var pitch := mouse_position.y

	HPivot.rotate_y(-yaw)

	VPivot.rotate_x(-pitch)
	VPivot.rotation.x = clamp(VPivot.rotation.x, -PI/4, PI/4)

func holster() -> void:
	update_equipped_weapon()
	
	if equippedWeapon:
		equippedWeapon.queue_free()
		equippedWeapon = null
	else:
		equip_selected_weapon()

func select_weapon() -> void:
	update_equipped_weapon()

	if equippedWeapon:
		# @todo: if equipped weapon is same as selected, then we queue_free
		# otherwise, we queue_free and then equip selected
		equippedWeapon.queue_free()
		equippedWeapon = null

	equip_selected_weapon()

func update_equipped_weapon() -> void:
	var weapon_children : Array[Weapon] = []

	for child in Hand.get_children():
		if child is Weapon:
			weapon_children.append(child)

	if weapon_children.size() > 0:
		equippedWeapon = weapon_children[0]
	else:
		equippedWeapon = null

func equip_selected_weapon() -> void:
	match selectedWeapon:
		WEAPONS.PISTOL:
			var weapon = Pistol.instantiate()
			Hand.add_child(weapon)
			equippedWeapon = weapon
		WEAPONS.RIFLE:
			var weapon = Rifle.instantiate()
			Hand.add_child(weapon)
			equippedWeapon = weapon

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = event.relative

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if Input.is_action_just_pressed("holster"):
		holster()

	if Input.is_action_just_pressed("select_weapon_1"):
		selectedWeapon = WEAPONS.PISTOL
		select_weapon()

	if Input.is_action_just_pressed("select_weapon_2"):
		selectedWeapon = WEAPONS.RIFLE
		select_weapon()

func _process(delta: float) -> void:
	handle_rotation(delta)

func _physics_process(delta: float) -> void:
	handle_movement(delta)
