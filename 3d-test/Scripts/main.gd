extends Node3D

var max_obstacles: float = 100

var spawn_loc = Vector3(0, 1, 0)
@onready var player = $Player

var obstacles_arr: Array = []

var player_dead = false

func _player_died(reason):
	if !player_dead:
		player_dead = true
		player.can_move = false
		$Gui/DeathScreen.visible = true
		$Gui/DeathScreen/Label.text = "You died to " + reason
		for obj in $Obstacles.get_children():
			obj.queue_free()
			await get_tree().create_timer(0.5 / $Obstacles.get_child_count()).timeout
		player.can_move = true
		create_tween().tween_property(player, "position", spawn_loc, 0.5)
		await get_tree().create_timer(0.5).timeout
		player.queue_free()
		player = load("res://Scenes/player.tscn").instantiate()
		add_child(player)
		player_dead = false
		$Gui/DeathScreen.visible = false
		_start_game()
	
func _create_warning():
	var path = "res://Scenes/Warning.tscn"
	var obj = load(path)
	if obj:
		obj = obj.instantiate()
	return obj

func _spawn_obstacles():
	var folder = ResourceLoader.list_directory("res://Scenes/Obstacles")
	var obstacles = Array(folder)
	var path = "res://Scenes/Obstacles/" + obstacles.pick_random()
	var rand_obstacle = load(path)
	var warning = _create_warning()
	if rand_obstacle:
		rand_obstacle = rand_obstacle.instantiate()
		
		var mesh = rand_obstacle.get_node_or_null("MeshInstance3D")
		if mesh and mesh is MeshInstance3D and mesh.get_active_material(0):
			mesh.mesh.material.albedo_color = Color(randf(), randf(), randf())
		
		var size_rng = randi_range(1, 3)
		if size_rng == 1:
			rand_obstacle.scale *= randf_range(2, 5)
		
		rand_obstacle.position.x = randf_range(player.position.x - 25, player.position.x + 25)
		rand_obstacle.position.z = randf_range(player.position.z - 25, player.position.z + 25)
		
		if player.position.y != 0:
			rand_obstacle.position.y = randf_range(player.position.y - 5, player.position.y + 5)
		else:
			rand_obstacle.position.y = randf_range(player.position.y, player.position.y + 5)
		
		var extra_rot = 0
		var extra_rot_rng = randi_range(1, 2)
		if extra_rot_rng:
			extra_rot = randf_range(0, 2 * PI)
		
		rand_obstacle.rotation.y += randi_range(-4, 4) * (PI / 2 + extra_rot)
		rand_obstacle.rotation.x += randi_range(-4, 4) * (PI / 2 + extra_rot)
		rand_obstacle.rotation.z += randi_range(-4, 4) * (PI / 2 + extra_rot)
		
		obstacles_arr.append(rand_obstacle)
		
		rand_obstacle.add_child(warning)
		$Obstacles.add_child(rand_obstacle)
	if rand_obstacle is Area3D and !rand_obstacle.get_script():
		await get_tree().create_timer(0.5).timeout
		if rand_obstacle:
			rand_obstacle.body_entered.connect(func(_body):
				_player_died(path.get_file().get_basename())
			)
	if warning:
		warning.queue_free()
		
func _start_game():
	while !player_dead:
		for obstacle in obstacles_arr:
			if obstacle == null:
				obstacles_arr.erase(obstacle)
		if len(obstacles_arr) < max_obstacles:
			_spawn_obstacles()
		await get_tree().create_timer(randf_range(0.1, 0.7)).timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_dead and player:
		player.velocity = Vector3.ZERO
		player.get_node("Trail").visible = true
