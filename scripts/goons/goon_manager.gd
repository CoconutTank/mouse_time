class_name GoonManager
extends Node


signal goon_tick


enum GOON_TYPE {
	DIZZY_MOLE,
	FIGHTY_LOBSTER,
	#SNEAKY_RAT,
	#WAVY_BIRD,
	#BIZZY_BEE,
	#PUFFY_TRUFFLE,
	#BLAMMY_CLAM,
	#SCRUFFY_SCUFFLER
}
var goon_prints = {}
var goon_ongoing_spawn_delay = {}
var goon_spawn_delay = {}
var goon_max_spawn_count = {}
var goon_total_max_spawn_count


const fight_text_duration = 0.5
const fight_cloud_shrink_duration = 0.1
var fight_text_anim
var fight_cloud_anim


var spawn_area_min : Vector2
var spawn_area_max : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	init_goon_prints()
	init_fight_cloud_anims()
	init_goon_spawn_details()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Map the nodes to their appropriate goon types.
func init_goon_prints():
	goon_prints[GOON_TYPE.DIZZY_MOLE] = load("res://nodes/goons/dizzy_mole.tscn")
	goon_prints[GOON_TYPE.FIGHTY_LOBSTER] = load("res://nodes/goons/fighty_lobster.tscn")


func init_goon_spawn_details():
	# Generic goon spawning details
	goon_total_max_spawn_count = 10

	# Dizzy Mole spawning details
	goon_spawn_delay[GOON_TYPE.DIZZY_MOLE] = 4
	goon_ongoing_spawn_delay[GOON_TYPE.DIZZY_MOLE] = 3
	goon_max_spawn_count[GOON_TYPE.DIZZY_MOLE] = 7

	# Fighty Lobster spawning details
	goon_spawn_delay[GOON_TYPE.FIGHTY_LOBSTER] = 9
	goon_ongoing_spawn_delay[GOON_TYPE.FIGHTY_LOBSTER] = 4
	goon_max_spawn_count[GOON_TYPE.FIGHTY_LOBSTER] = 5


func init_fight_cloud_anims():
	fight_text_anim = load("res://nodes/fight_text/fight_text.tscn")
	fight_cloud_anim = load("res://nodes/fight_text/fight_cloud.tscn")


# Spawns a goon of the given type.
# Each goon handles its own spawning positioning.
# If an invalid goon type is specified, null is returned.
func spawn_goon(goon_type : GOON_TYPE):
	if goon_type in GOON_TYPE.values():
		var goon_type_str = goon_type_to_string(goon_type)
		var goon = goon_prints[goon_type].instantiate()
		goon.set_spawn_position(spawn_area_min, spawn_area_max)
		if goon.has_method("on_goon_tick"):
			goon_tick.connect(Callable(goon, "on_goon_tick"))
		add_child(goon)
		goon.add_to_group(goon_type_str + "_population")
		goon.add_to_group("goon_population")
		return goon
	else:
		print("!! Unknown goon type value: " + str(goon_type) + " !!")
		return null


# The life of a goon is potentially brief.
# Goons can't fight opponents that are invulnerable.
func goon_fight(goon, opponent):
	if !opponent.invulnerable:
		goon.hide()
		goon.active = false
		opponent.hide()
		opponent.active = false
		await show_random_fight_cloud_at(goon.position)
		if goon.has_method("on_fight"):
			goon.on_fight(opponent)
		opponent.show()
		if opponent.keep_going():
			opponent.active = true
			opponent.activate_invul()


# Spawns a fight cloud with random fight text at the given position.
func show_random_fight_cloud_at(pos : Vector2):
	var fight_cloud = fight_cloud_anim.instantiate()
	var fight_text = fight_text_anim.instantiate()
	fight_cloud.get_node("FightCloudAnims").position = pos
	fight_text.get_node("FightTextAnims").position = pos
	add_child(fight_cloud)
	add_child(fight_text)
	var fight_text_names = fight_text.get_node("FightTextAnims").sprite_frames.get_animation_names()
	fight_cloud.get_node("FightCloudAnims").play("default")
	fight_text.get_node("FightTextAnims").play(fight_text_names[randi() % fight_text_names.size()])
	await get_tree().create_timer(fight_text_duration).timeout
	fight_text.queue_free()
	fight_cloud.get_node("FightCloudAnims").play("shrink")
	await get_tree().create_timer(fight_cloud_shrink_duration).timeout
	fight_cloud.queue_free()


func goon_type_to_string(goon_type : GOON_TYPE):
	if goon_type in GOON_TYPE.values():
		return str(GOON_TYPE.keys()[goon_type])
	else:
		print("!! Unknown goon type value: " + str(goon_type) + " !!")
		return null


# Emits the goon_tick signal every second.
# Also handles periodic goon spawning.
func _on_goon_timer_timeout():
	for goon_type in goon_spawn_delay.keys():
		goon_spawn_delay[goon_type] = goon_spawn_delay[goon_type] - 1
		if goon_spawn_delay[goon_type] <= 0:
			goon_spawn_delay[goon_type] = goon_ongoing_spawn_delay[goon_type]
			if within_spawn_limits(goon_type):
				spawn_goon(goon_type)
	goon_tick.emit()


func stop_all_goons():
	for goon in get_tree().get_nodes_in_group("goon_population"):
		goon.linear_velocity = Vector2.ZERO
		goon.game_is_active = false
		goon.active = false


func reset():
	init_goon_spawn_details()
	zap_all_goons()


func zap_all_goons():
	get_tree().call_group("goon_population", "queue_free")


# Checks if the given goon type can currently be spawned.
func within_spawn_limits(goon_type : GOON_TYPE):
	return get_total_goon_count() < goon_total_max_spawn_count && get_goon_count(goon_type) < goon_max_spawn_count[goon_type]


# Returns a count of the number of goons of a specific type
func get_goon_count(goon_type : GOON_TYPE):
	if goon_type in GOON_TYPE.values():
		var goon_type_str = str(GOON_TYPE.keys()[goon_type])
		return get_tree().get_nodes_in_group(goon_type_str + "_population").size()
	else:
		print("!! Unknown goon type value: " + str(goon_type) + " !!")
		return 0


# Returns the total number of goons at this time.
func get_total_goon_count():
	return get_tree().get_nodes_in_group("goon_population").size()
