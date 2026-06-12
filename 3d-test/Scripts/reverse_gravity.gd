extends Area3D

var player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Main/OmniLight3D.omni_range *= scale.y
		
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		player = body
		player.gravity_direction *= -1
		
		var text = "+"
		if player.gravity_direction < 0:
			text = "-"
		$MeshInstance3D.mesh.text = text
		
func _on_body_exited(body: Node3D) -> void:
	if body == player:
		player = null
