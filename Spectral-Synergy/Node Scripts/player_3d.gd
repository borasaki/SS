extends CharacterBody3D

@export var SPEED = 1.2
@export var JUMP_VELOCITY = 4.5

@onready var cam = $Camera3D
@onready var anim = $animations

var syncPos = Vector3(0,0,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	cam.make_current()
	if self.get_name().to_int() == 1 :
		$UI.show()

enum dir {left, right, up, down}
enum gaite {idle, walk, sprint}

var travel = dir.left
var move = gaite.idle

func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		cam.current = true
		var effSpeed = SPEED
		if not is_on_floor():
			velocity.y -= gravity * delta

		syncPos = global_position
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
		if Input.is_action_pressed("Shift"):
			move = gaite.sprint
			effSpeed = SPEED*1.5
		else:
			move = gaite.walk
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * effSpeed
			velocity.z = direction.z * effSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, effSpeed)
			velocity.z = move_toward(velocity.z, 0, effSpeed)
			
		anime(velocity.x,velocity.z)
		
		move_and_slide()
	else:
		global_position = global_position.lerp(syncPos, .2)
	if $UI/Chat/RichTextLabel.has_focus():
		$UI/Chat/RichTextLabel.set_scroll_follow(false)
	if not $UI/Chat/RichTextLabel.has_focus():
		$UI/Chat/RichTextLabel.set_scroll_follow(true)

func anime(x,z):
	if x == 0 and z == 0:
		move = gaite.idle
		match travel:
			dir.left:
				anim.play("IdleSide")
				anim.flip_h = false
			dir.right:
				anim.play("IdleSide")
				anim.flip_h = true
			dir.up:
				anim.play("IdleUp")
			dir.down:
				anim.play("IdleBack")
	if z > 0 and x == 0:
		travel = dir.down
		match move:
			gaite.walk:
				anim.play("WalkDown")
			gaite.sprint:
				anim.play("RunDown")
	if z < 0 and x == 0:
		travel = dir.up
		match move:
			gaite.walk:
				anim.play("WalkUp")
			gaite.sprint:
				anim.play("RunUp")
	if x < 0:
		travel = dir.left
		match move:
			gaite.walk:
					anim.play("SideWalk")
					anim.flip_h = false
			gaite.sprint:
					anim.play("SideRun")
					anim.flip_h = false
	if x > 0:
		travel = dir.right
		match move:
			gaite.walk:
				anim.play("SideWalk")
				anim.flip_h = true
			gaite.sprint:
				anim.play("SideRun")
				anim.flip_h = true
	
	pass

# Player message items
@rpc("any_peer","call_local")
func send_message():
	if $UI/Chat/chatInput.text != "":
		var message = $UI/Chat/chatInput.text
		var id = multiplayer.get_unique_id()
		var user = GameManager.Players[id].name
		rpc("receive_message", user, message)
		$UI/Chat/chatInput.text = ""
	
@rpc("any_peer","call_local")	
func receive_message(user, message):
	$UI/Chat/RichTextLabel.text += "%s: %s\n" % [user, message]
#	if not $UI/Chat/TextEdit.has_focus():
#		$UI/Chat/TextEdit.set_v_scroll($UI/Chat/TextEdit.get_line_count())
		
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode==KEY_ENTER:
		send_message()


func _on_send_button_button_down():
	send_message()
	pass # Replace with function body.
