class_name Weapon

extends Node3D

@export var AimCast: RayCast3D
@export var GunMesh: MeshInstance3D
@export var AudioShoot: AudioStreamPlayer

@export var IsAutomatic := false
@export var RecoilTimer := 0.10
@export var RecoilZPosition := 0.10

@onready var BulletDecal := preload("res://decals/bullet_hit/bullet_hit.tscn")

var recoil_tween: Tween

func _physics_process(_delta: float) -> void:
	if recoil_tween:
		if not recoil_tween.is_running():
			if IsAutomatic and Input.is_action_pressed("shoot"):
				shoot()
			elif Input.is_action_just_pressed("shoot"):
				shoot()
	else:
		if IsAutomatic and Input.is_action_pressed("shoot"):
			shoot()
		elif Input.is_action_just_pressed("shoot"):
			shoot()

func shoot() -> void:
	animate_recoil()
	AudioShoot.play()

	var collider = AimCast.get_collider()

	if collider:
		# @todo: figure out why the decal doesn't show on the walls, only on the floor
		var decal = BulletDecal.instantiate()
		collider.add_child(decal)

		decal.transform.origin = AimCast.get_collision_point()
		decal.look_at(AimCast.get_collision_point() + AimCast.get_collision_normal(), Vector3.UP)

func animate_recoil() -> void:
	recoil_tween = get_tree().create_tween()

	recoil_tween.tween_property(GunMesh, "position", Vector3(0, 0, RecoilZPosition), RecoilTimer)
	recoil_tween.tween_property(GunMesh, "position", Vector3.ZERO, RecoilTimer)
	
