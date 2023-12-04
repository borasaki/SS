extends Node3D

@export var playerScene : PackedScene


func _ready():
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = playerScene.instantiate()
#		currentPlayer.get_child()
		currentPlayer.name = str(GameManager.Players[i].id)
		add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawn"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index+=1
	pass
