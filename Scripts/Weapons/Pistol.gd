extends Spatial

var damage = 10
#flag for infinite ammo
export var unlimited := true
#this should be a max(i.e. readonly)
var ammo = 100
#this should also be a reference
var ammo_consumption = 1
#full auto
var time_btw_fire := 0
onready var curr_time_btw_fire := time_btw_fire

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var weapon_cast = player.aim_cast
var active_mutation

func _ready():
	pass

func _process(delta):
	active_mutation = player.weapon_manager.current_pistol_mutation
	print(active_mutation)
	if curr_time_btw_fire > 0:
		curr_time_btw_fire -= 1
	if weapon_cast.is_colliding() and weapon_cast.is_in_group("enemy"):
		print("enemy found")

#this will shoot the ray out
func shoot():
	if curr_time_btw_fire <= 0:
		if !unlimited and ammo >= ammo_consumption:
			ammo -= ammo_consumption
		#not sure why this works, but if it doesn't for other guns
		#have it look for the look cast in the player script and take info from that
		if weapon_cast.is_colliding():
			var target = weapon_cast.get_collider()
			if target.is_in_group("enemy"):
				var enemy = weapon_cast.get_collider()
				match active_mutation:
					"double":
						enemy.take_damage(damage * 2)
					_:
						enemy.take_damage(damage)
		#curr_time_btw_fire = time_btw_fire
	
