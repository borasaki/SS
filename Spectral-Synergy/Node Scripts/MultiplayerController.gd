extends Control

@export var ADDRESS = "127.0.0.1"
@export var PORT = 64

@export var playerScene: PackedScene
@export var lobby: Node
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	#For lan server
	if "--server" in OS.get_cmdline_args():
		hostGame()
	pass
	
# Called on BOTH server and clients

func peer_connected(id):
	print("Player Connected: "+str(id))
	# add_player(id)
	
func add_player(id):
	var player = playerScene.instantiate()
	player.name = str(id)
		
	lobby.add_child(player)
	self.hide()
	pass
# Called on BOTH server and clients
func peer_disconnected(id):
	print("Player Disconnected: "+str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()
	

# ONLY CLIENTS, when client connects to server
func connected_to_server():
	playerStream.rpc_id(1, multiplayer.get_unique_id(), $userInput.text) # Calls the playerStream that sends the player information to the server
	print("Connected to Server!")

# ONLY CLIENTS
func connection_failed(id):
	print("Failed to Connect to Server...")

#FOR FUTURE: pass in usernames, passwords, their icons, their player id or whatever for account based game
#I have also set it to ID then name because the ID I believe should be more improtant than the player name in most instances
@rpc("any_peer")
func playerStream(id, name):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
									"id": id,
									"name": name
									}
	if multiplayer.is_server():
		for i in GameManager.Players:
			playerStream.rpc(i, GameManager.Players[i].name)
	
func _on_host_button_down():
	hostGame()
	playerStream(multiplayer.get_unique_id(), $userInput.text)
	pass


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS, PORT)
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	#############################################
#	var player = playerScene.instantiate()
#	player.name = str(multiplayer.get_unique_id())
#
#	lobby.add_child(player)
#	self.hide()

	pass

# Calls rpc with this config, everyone connected and yourself included
func _on_start_button_down():
	startGame.rpc()
	pass
	
@rpc("any_peer","call_local")
func startGame():
	var scene = load("res:///Game Scenes/world.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 16)
	
	if error != OK:
		print("Cannot Host: "+error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer) #Asked Godot to make a server and created a peer to host the server
	print("Waiting for players...")
	pass
