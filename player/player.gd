extends CharacterBody3D

@export var HorizontalPivot: Node3D

@export var Jump := 4.5
@export var RunSpeed := 7.5
@export var AimSpeed := 3.0
@export var WalkSpeed := 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(delta: float):
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
	var h_rotation = HorizontalPivot.global_transform.basis.get_euler().y
	var direction = input.rotated(-h_rotation).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.y * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.y, 0, speed)

	move_and_slide()
