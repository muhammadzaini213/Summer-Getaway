extends Node

var bgm: AudioStreamPlayer
var sfx_holder: Node
const TYPEWRITER = "res://Assets/Audio/sfx_typewriter.mp3"

const OPEN_DOOR = "res://Assets/Audio/sfx_openDoor.mp3"

const CLOSE_DOOR = "res://Assets/Audio/sfx_closeDoor.mp3"

const NOTICE = "res://Assets/Audio/sfx_notice.wav"

const CLICK = "res://Assets/Audio/sfx_click.mp3"


func _ready():

	bgm = AudioStreamPlayer.new()

	bgm.bus = "Music"

	add_child(bgm)

	sfx_holder = Node.new()

	add_child(sfx_holder)


func play_bgm(path: String):

	if bgm.stream:

		if bgm.stream.resource_path == path:

			return

	bgm.stream = load(path)

	bgm.play()


func stop_bgm():

	bgm.stop()


func play_sfx(path: String):

	var player = AudioStreamPlayer.new()

	player.bus = "SFX"

	player.stream = load(path)

	sfx_holder.add_child(player)

	player.play()

	player.finished.connect(player.queue_free)
