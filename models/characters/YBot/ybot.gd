class_name CharacterModel

extends Node3D

@export var StrafeSpeed := 2.0
@export var AnimTree: AnimationTree

enum MOVEMENT {
	IDLE,
	WALK,
	RUN,
}

var target_blend := -1.0
var is_strafing := false
var strafe := Vector3.ZERO
var strafe_direction := Vector3.ZERO
var target_strafe_transition := "not_strafing"

func set_movement_animation(value: MOVEMENT) -> void:
	match value:
		MOVEMENT.IDLE:
			target_blend = -1
		MOVEMENT.WALK:
			target_blend = 0
		MOVEMENT.RUN:
			target_blend = 1

func set_strafing(value: bool) -> void:
	if value:
		target_strafe_transition = "strafing"
	else:
		target_strafe_transition = "not_strafing"

func update_movement_blend() -> void:
	var current_blend = AnimTree.get("parameters/movement_blend/blend_amount")
	AnimTree.set("parameters/movement_blend/blend_amount", lerp(current_blend, target_blend, 0.1))

func update_strafing() -> void:
	strafe = lerp(strafe, strafe_direction, 0.1)
	var target_strafe = Vector2(strafe.x, -strafe.z)

	AnimTree.set("parameters/strafe_transition/transition_request", target_strafe_transition)
	AnimTree.set("parameters/strafe/blend_position", target_strafe)

func _process(_delta: float) -> void:
	update_movement_blend()
	update_strafing()
