extends Node2D

enum State {WALK, BOUNCEWALK, IDLE, BOUNCEIDLE}
var state = State.WALK
var speed = 60
var direction = Vector2(1,1)

var screen_size = Vector2()
var window_size = Vector2(192,192)

var idle_timer = 0.0
var is_idling = false
@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D
var is_dragging = false
var drag_offset = Vector2()

var setting_speed = 60

var can_quack = true
var playing_music = false

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	
	animated_sprite.play("walk-normal")
	
	$DuckieMenu.add_item("Waddle",0)
	$DuckieMenu.add_item("Music",1)
	$DuckieMenu.add_item("Speed",2)
	$DuckieMenu.add_item("Size",3)
	
	area.input_event.connect(_on_area_input)
	$DuckieMenu.id_pressed.connect(_on_menu_pressed)

func _on_menu_pressed(id):
	if id == 0:
		if state == State.IDLE:
			state = State.WALK
		elif state == State.BOUNCEIDLE:
				state = State.BOUNCEWALK
	if id == 1:
		if !playing_music:
			$MusicPlayer.play()
			state = State.BOUNCEIDLE
			playing_music = true
		else:
			$MusicPlayer.stop()
			state = State.IDLE
			playing_music = false
	if id == 2:
		if setting_speed == 60:
			setting_speed = 300
			if state == State.IDLE:
				state = State.WALK
			elif state == State.BOUNCEIDLE:
				state = State.BOUNCEWALK
		elif setting_speed == 300:
			setting_speed = 60
			if state == State.IDLE:
				state = State.WALK
			elif state == State.BOUNCEIDLE:
				state = State.BOUNCEWALK
		

func _physics_process(delta: float) -> void:
	
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
	
	match state:
		State.WALK:
			speed = setting_speed
			animated_sprite.play("walk-normal")
		State.BOUNCEWALK:
			speed = setting_speed
			animated_sprite.play("walk-bounce")
		State.IDLE:
			speed = 0
			animated_sprite.play("idle-normal")
		State.BOUNCEIDLE:
			speed = 0
			animated_sprite.play("idle-bounce")
	
	
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	#print(window_position)
	window_position.x = clamp(window_position.x,0,screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y,0,screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	
	if window_position.x <= 0 or window_position.x >= screen_size.x-window_size.x:
		direction.x *= -1 
		animated_sprite.flip_h = !animated_sprite.flip_h
		
	if window_position.y <= 0 or window_position.y >= screen_size.y-window_size.y-50:
		direction.y *= -1 	


func _on_area_input(_viewport,event,_shape_idx):
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
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:	
		if state == State.WALK:
			state = State.IDLE
		elif state == State.BOUNCEWALK:
			state = State.BOUNCEIDLE
		$DuckieMenu.popup_on_parent(Rect2i(Vector2i(event.position),Vector2i.ZERO))
