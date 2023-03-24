class_name Holster

extends Node3D

enum WEAPONS {
	Pistol,
	Rifle
}

var equippedWeapon: Weapon
var selectedWeapon: WEAPONS = WEAPONS.Pistol

@onready var Rifle := preload("res://weapons/rifle/rifle.tscn")
@onready var Pistol := preload("res://weapons/pistol/pistol.tscn")
 
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("holster"):
		holster()

	if Input.is_action_just_pressed("select_weapon_1"):
		selectedWeapon = WEAPONS.Pistol
		select_weapon()

	if Input.is_action_just_pressed("select_weapon_2"):
		selectedWeapon = WEAPONS.Rifle
		select_weapon()

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

	for child in get_children():
		if child is Weapon:
			weapon_children.append(child)

	if weapon_children.size() > 0:
		equippedWeapon = weapon_children[0]
	else:
		equippedWeapon = null

func equip_selected_weapon() -> void:
	match selectedWeapon:
		WEAPONS.Pistol:
			var weapon = Pistol.instantiate()
			add_child(weapon)
			equippedWeapon = weapon
		WEAPONS.Rifle:
			var weapon = Rifle.instantiate()
			add_child(weapon)
			equippedWeapon = weapon
