extends Area2D
class_name CaptureableBase

signal base_captured(new_team)

export (Color) var neutral_color = Color(1, 1, 1)
export (Color) var player_color = Color(0.596078, 0.521569, 1)
export (Color) var enemy_color = Color(0.827451, 0.223529, 0.223529)

var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: int = Team.TeamName.NEUTRAL

onready var team = $Team
onready var capture_timer = $CaptureTimer
onready var sprite = $Sprite

func _on_CaptureBase_body_entered(body: Node) -> void:
	if body.has_method("get_team"):
		var body_team = body.get_team()

		if body_team == Team.TeamName.ENEMY:
			enemy_unit_count += 1
		elif body_team == Team.TeamName.PLAYER:
			player_unit_count += 1
#		else:
#			capture_timer.stop()
	
		check_whether_base_can_be_capture()


func _on_CaptureBase_body_exited(body: Node) -> void:
	if body.has_method("get_team"):
		var body_team = body.get_team()
		

		if body_team == Team.TeamName.ENEMY:
			enemy_unit_count -= 1
		elif body_team == Team.TeamName.PLAYER:
			player_unit_count -= 1

		check_whether_base_can_be_capture()

func check_whether_base_can_be_capture():
	var majority_team = get_team_with_majority()
	
	if majority_team == Team.TeamName.NEUTRAL:
		return
	elif majority_team == team.team:
		#stop counttoun if start
		print("team who have majority, stop capturing")
		team_to_capture = Team.TeamName.NEUTRAL
		capture_timer.stop()
	else:
		#start coundown capture
		print("new team start capture")
		team_to_capture = majority_team
		capture_timer.start()



func get_team_with_majority() -> int:
	if enemy_unit_count == player_unit_count:
		return Team.TeamName.NEUTRAL
	elif enemy_unit_count > player_unit_count:
		return Team.TeamName.ENEMY
	else:
		return Team.TeamName.PLAYER

func set_team(new_team: int):
	team.team = new_team
	emit_signal("base_captured", new_team)
	match new_team:
		Team.TeamName.NEUTRAL:
			sprite.modulate = neutral_color
			return
		Team.TeamName.PLAYER:
			sprite.modulate = player_color
		Team.TeamName.ENEMY:
			sprite.modulate = enemy_color
			return


func _on_CaptureTimer_timeout() -> void:
	set_team(team_to_capture)
