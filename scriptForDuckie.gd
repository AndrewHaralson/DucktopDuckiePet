extends Node2D

var speed = 60.0
var direction = Vector2(1,1)
var screen_size = Vector2()
var window_size = Vector2(192,192)

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	print(screen_size)

func _physics_process(delta: float) -> void:
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	print(window_position)
	window_position.x = clamp(window_position.x,0,screen_size.x - window_size.x)
	window_position.y = clamp(window_position.y,0,screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	
	if window_position.x <= 0 or window_position.x >= screen_size.x-192:
		direction.x *= -1 
	if window_position.y <= 0 or window_position.y >= screen_size.y-242:
		direction.y *= -1 	
