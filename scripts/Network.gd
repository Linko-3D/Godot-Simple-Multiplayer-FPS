extends Node

var lobby = "res://scenes/Lobby.tscn"
var map = "res://scenes/Map.tscn"
var player = "res://scenes/Player.tscn"
var spawn = null

var mute = false

func _physics_process(delta):
	if Input.is_action_just_pressed("mute"):
		mute = !mute
		AudioServer.set_bus_mute(0, mute)

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(4242, 16)
	get_tree().set_network_peer(peer)

	load_game()

func join_server(ip):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, 4242)
	get_tree().set_network_peer(peer)

	load_game()

func load_game():
	get_tree().change_scene(map)
	
	yield(get_tree().create_timer(0.01), "timeout")	
	spawn = get_tree().get_root().find_node("Spawn", true, false)
	
	if not get_tree().is_network_server():
		spawn_player( get_tree().get_network_unique_id() )
	
func spawn_player(id):
	var player_instance = load(player).instance()
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	spawn.add_child(player_instance)

func _on_network_peer_connected(id):
	if id != 1:
		spawn_player(id)

func _on_network_peer_disconnected(id):
	get_tree().get_root().find_node(str(id), true, false). queue_free()

func _on_server_disconnected():
	get_tree().change_scene(lobby)
