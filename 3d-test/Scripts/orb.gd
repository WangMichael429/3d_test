extends Area3D

var player = null

@export var velocity = -100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if velocity < 0:
		$MeshInstance3D.mesh.text = str(velocity)
	$Main/OmniLight3D.omni_range *= scale.y
		
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		

func _on_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
		
func _process(_delta: float) -> void:
	if player and player.dashing:
		player.velocity.y = velocity
