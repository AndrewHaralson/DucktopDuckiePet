#DESKTOP DUCKIE PET!!!!!!!!!!
#Made by Andrew Haralson
#Thanks to caz-bee on itch.io for the sprites and animations

extends Node2D

#speed and direction variables
enum State {WALK, BOUNCEWALK, IDLE, BOUNCEIDLE}
var state = State.WALK
var speed = 60
var setting_speed = 60
var direction = Vector2(1,1)

#window variables
var screen_size = Vector2()
var window_size = Vector2(192,192)

#animation variables
@onready var animated_sprite = $AnimatedSprite2D
var animation_speed = 1

#sound variables
var can_quack = true
var playing_music = false

#dragging variables
@onready var area = $Area2D
var is_dragging = false
var drag_offset = Vector2()

#throw variables
var velocity = Vector2()
var last_mouse = Vector2(0,0)

#when program starts
func _ready():
	#grab screen size
	screen_size = Vector2(DisplayServer.screen_get_size())
	
	#default starting animation
	animated_sprite.play("walk-normal")
	
	#adds menu options
	$DuckieMenu.add_item("Waddle",0)
	$DuckieMenu.add_item("Music",1)
	$DuckieMenu.add_item("Speed",2)
	
	#lets the buttons actually be clicked
	area.input_event.connect(_on_area_input)
	$DuckieMenu.id_pressed.connect(_on_menu_pressed)

#rightclick menu
func _on_menu_pressed(id):
	
	#tell duckie to waddle!
	if id == 0:
		if state == State.IDLE:
			state = State.WALK
		elif state == State.BOUNCEIDLE:
				state = State.BOUNCEWALK
	
	#toggles music! (and makes duckie dance to it)
	#(ode to joy rn but imma use some music i bought)
	#(shoutout to the strawberry jam soundtrack for being so peak)
	#(genuinely its almost toby fox level peak)
	elif id == 1:
		if !playing_music:
			$MusicPlayer.play()
			state = State.BOUNCEIDLE
			playing_music = true
		else:
			$MusicPlayer.stop()
			state = State.IDLE
			playing_music = false
	
	#toggles duckie speeeeeeed
	elif id == 2:
		if setting_speed == 60:
			setting_speed = 300
		elif setting_speed == 300:
			setting_speed = 60	
	
	#lowk wanna add a size changing button
	
#physics loop	
func _physics_process(delta: float) -> void:
	
	#throws or drags duckie
	if is_dragging:
		#calculates how much to offset duckie when dragged
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		
		#calculates velocity to throw duckie from mouse movement
		var mouse = Vector2(DisplayServer.mouse_get_position())
		velocity = (mouse - last_mouse) / delta
		last_mouse = mouse
	
	#shrinks throw velocity so duckie doesnt bounce forever
	velocity = velocity.lerp(Vector2.ZERO, 1 * delta)
	
	#changes animation speed when speed is toggled
	if setting_speed == 300:
		animation_speed = 2
	else:
		animation_speed = 1
		
	#plays the correct animation for duckie
	match state:
		State.WALK:
			speed = setting_speed
			animated_sprite.play("walk-normal",animation_speed)
		State.BOUNCEWALK:
			speed = setting_speed
			animated_sprite.play("walk-bounce",animation_speed)
		State.IDLE:
			speed = 0
			animated_sprite.play("idle-normal",animation_speed)
		State.BOUNCEIDLE:
			speed = 0
			animated_sprite.play("idle-bounce",animation_speed)
	
	#find where duckie is
	var window_position = Vector2(DisplayServer.window_get_position())
	
	#duckie gets thrown when the throw power is high enough
	if (velocity.length()>(setting_speed)):
		window_position += velocity * delta	
	#otherwise duckie waddles away
	else:
		window_position += direction * speed * delta
		velocity = Vector2(0,0)
	
	#keeps duckie on screen (i think linux already does this tho)
	window_position.x = clamp(window_position.x,0,screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y,0,screen_size.y - window_size.y)
	
	#moves duckie!
	DisplayServer.window_set_position(Vector2i(window_position))
	
	#keeps duckie sprite aligned with the direction hes walking
	if direction.x>0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	#bounces duckie when he is thrown into a side of the screen
	if (window_position.x <= 0) and (velocity.x<0):
		velocity.x *= -1
	elif (window_position.x >= screen_size.x-window_size.x) and (velocity.x>0):
		velocity.x *= -1
	
	#turns duckie around when he bumps into a side of the screen
	if (window_position.x <= 0) and (direction.x<0):
		direction.x *= -1
	elif (window_position.x >= screen_size.x-window_size.x) and (direction.x>0):
		direction.x *= -1 
	
	#bounces duckie off the top and bottom of the screen
	if window_position.y <= 0 or window_position.y >= screen_size.y-window_size.y-50:
		direction.y *= -1
		velocity.y *= -1 	

#when duckie is clicked
func _on_area_input(_viewport,event,_shape_idx):
	
	#on leftclick duckie will quack and can be dragged
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			if can_quack:
				$QuackPlayer.play()
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false
	
	#on rightclick duckie will sit and bring up the menu
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:	
		if state == State.WALK:
			state = State.IDLE
		elif state == State.BOUNCEWALK:
			state = State.BOUNCEIDLE
		$DuckieMenu.popup_on_parent(Rect2i(Vector2i(event.position),Vector2i.ZERO))
