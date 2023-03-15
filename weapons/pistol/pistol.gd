extends Node3D

@export var GunCast: RayCast3D

func _physics_process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot():
	if GunCast.is_colliding():
		print("Gun hit!")
