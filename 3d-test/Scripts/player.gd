extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 9

var dashed: bool = false

var dashing: bool = false
var can_move: bool = true
var can_dash: bool = true

var dash_time: float = 0
var prev_dash_time: float = 0

var dashes: int = 0

var gravity_direction: float = 1

var current_direction = null

var timer: float = 0
var dash_cooldown: float = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and can_dash:
		dashing = true
		dashes += 1
		if !dashed:
			dashed = true
	elif event.is_action_released("dash") or !can_dash:
		dashing = false
	elif dash_time >= 0.5:
		dash_time = 0
		dashing = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() or gravity_direction < 0 and !is_on_ceiling():
		velocity += get_gravity() * gravity_direction * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and can_move:
		current_direction = direction
		$Main.visible = false
		$Trail.emitting = true
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		current_direction = null
		$Main.visible = true
		$Trail.emitting = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if dashing:
		dash_time += delta
		var multiplier = 1
		#multiplier += prev_dash_time
		
		if current_direction:
			velocity = current_direction * SPEED * multiplier #* dash_time
		else:
			velocity.y = SPEED * 4 * gravity_direction * multiplier #* dash_time
		$Main.visible = false
		$Trail.emitting = true
		velocity.x *= 4
		velocity.z *= 4
	
	if velocity.y != 0 and !current_direction:
		$Main.visible = false
		$Trail.emitting = true
	
	if dashing:
		timer += delta
	else:
		timer = 0
		
	if dashes > 2 and timer <= 0.5:
		timer = 0
		dashes = 0
		can_dash = false
	
	if !can_dash:
		dash_cooldown += delta
	else:
		dash_cooldown = 0
		
	if dash_cooldown >= 1:
		can_dash = true
		
	print(" Dashes: ", dashes, "\nTimer: ", timer, "\n can dash: ", can_dash, "\n cooldown:", dash_cooldown)
	
	move_and_slide()
