class_name Weapon

extends Node3D

@export var AimCast: RayCast3D

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if AimCast.get_collider():
		print("Collider: ", AimCast.get_collider())

	if AimCast.is_colliding():
		print("Weapon hit!")
