extends Node2D


enum BaseCaptureStartOrder{
	FIRST,
	LAST
}


export (BaseCaptureStartOrder) var base_capture_start_order
export (Team.TeamName) var team_name = Team.TeamName.NEUTRAL
export (PackedScene) var unit = null
export(int) var max_units_alive = 5

var target_base: CaptureableBase = null
var captureable_base: Array = []
var respawn_point: Array = []
var next_spawn_to_use: int = 0

onready var team = $Team
onready var unit_container = $UnitContainer
onready var respawn_timer = $RespawnTimer

func initialize(captureable_base: Array, respawn_point: Array):
	if captureable_base.size() == 0 or respawn_point.size() == 0 or unit == null:
		push_error("forgot to init map ai")
		return

	team.team = team_name

	self.respawn_point = respawn_point
	for respawn in respawn_point:
		spawn_unit(respawn.global_position)

	self.captureable_base = captureable_base

	for base in captureable_base:
		base.connect("base_captured", self, "handle_base_captured")

	chect_for_next_capturable_base()


func handle_base_captured(_new_team: int):
	chect_for_next_capturable_base()

func chect_for_next_capturable_base():
	var next_base = get_next_captureable_base()
	if next_base != null:
		target_base = next_base
		assign_next_captureable_base_to_units(next_base)

func get_next_captureable_base():
#base capture start order first
	var list_of_base =  range(captureable_base.size())
	if base_capture_start_order == BaseCaptureStartOrder.LAST:
		list_of_base = range(captureable_base.size() -1, -1, -1)
 
	for i in list_of_base:
		var base: CaptureableBase = captureable_base[i]
		if team.team != base.team.team:
			print("assigning team %d to capture base %d" % [team.team, i])
			return base

	return null

func assign_next_captureable_base_to_units(base: CaptureableBase):
	for unit in unit_container.get_children():
		set_unit_ai_to_advance_to_next_base(unit)

func spawn_unit(spawn_location: Vector2):
	var unit_instance = unit.instance()
	unit_container.add_child(unit_instance)
	unit_instance.global_position = spawn_location
	unit_instance.connect("died", self, "handle_unit_death")
	set_unit_ai_to_advance_to_next_base(unit_instance)

func set_unit_ai_to_advance_to_next_base(unit: Actor):
	if target_base != null:
		var ai: AI = unit.ai
		ai.next_base = target_base.global_position
		ai.set_state(AI.State.ADVANCE)

func handle_unit_death():
	if respawn_timer.is_stopped() and unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()


func _on_RespawnTimer_timeout() -> void:
	var respawn = respawn_point[next_spawn_to_use]
	spawn_unit(respawn.global_position)
	next_spawn_to_use +=1
	if next_spawn_to_use == respawn_point.size():
		next_spawn_to_use = 0

	if unit_container.get_children().size() < max_units_alive:
		respawn_timer.start()
