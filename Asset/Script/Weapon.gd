extends Node2D
class_name Weapon

signal weapon_out_of_ammo

export (PackedScene) var Bullet

var team: int = -1

var max_ammo: int = 10
var current_ammo: int = max_ammo

onready var end_of_gun = $EndOfGun
onready var gun_direction = $GunDirection
onready var attack_cooldown = $AttackCooldown
onready var animation_player = $AnimationPlayer
onready var shootefect = $ShootEfect

func _ready() -> void:
	shootefect.hide()

func initialize(team: int):
	self.team = team

func start_reload():
	animation_player.play("reload")

func _stop_reload():
	current_ammo = max_ammo

func shoot():
	if current_ammo != 0 and attack_cooldown.is_stopped() and Bullet != null:
			var bullet_instance = Bullet.instance()
			var direction = (gun_direction.global_position - end_of_gun.global_position).normalized()
			#	add_child(bullet_instance)
			#	bullet_instance.global_position = end_of_gun.global_position
			#	var target = get_global_mouse_position()
			#	var direction_to_mouse = end_of_gun.global_position.direction_to(target).normalized()
			#	bullet_instance.set_direction(direction_to_mouse)
			GlobalSignals.emit_signal("bullet_fired", bullet_instance, team, end_of_gun.global_position, direction)
			attack_cooldown.start()
			animation_player.play("New Anim")
			current_ammo -= 1
			if current_ammo == 0:
				emit_signal("weapon_out_of_ammo")
