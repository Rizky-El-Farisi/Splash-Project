extends Node2D

const Player = preload("res://Asset/Scene/Player.tscn")

onready var captureable_base_manager = $CaptureBaseManager
onready var bullet_manager = $BulletManager
onready var player: Player = $Player
onready var ally_ai = $AllyMapAI
onready var enemy_ai = $EnemyMapAI
onready var camera = $Camera2D

func _ready() -> void:
	randomize()
	GlobalSignals.connect("bullet_fired", bullet_manager, "handle_bullet_spawned")

	var ally_respawns = $AllyRespawnPoints
	var enemy_respawns = $EnemyRespawnPoints

	var base = captureable_base_manager.get_captureable_base()
	ally_ai.initialize(base, ally_respawns.get_children())
	enemy_ai.initialize(base, enemy_respawns.get_children())

	spawn_player()

func spawn_player():
	var player = Player.instance()
	add_child(player)
	player.set_camera_transform(camera.get_path())
	player.connect("died", self, "spawn_player")

