@tool
extends Node2D

# Only one piece can be held at a time (shared by all pieces)
static var held_piece: Node2D = null

@export var size := Vector2(200, 200):
	set(value):
		size = value
		queue_redraw()

@export var color := Color.ORANGE:
	set(value):
		color = value
		queue_redraw()

var touch_index := -1          # which finger is holding this piece
var grab_offset := Vector2.ZERO  # keeps the piece from jumping to the finger


func _draw() -> void:
	draw_rect(Rect2(-size / 2, size), color)


func _contains(screen_point: Vector2) -> bool:
	return Rect2(-size / 2, size).has_point(to_local(screen_point))


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	# Finger down / finger up
	if event is InputEventScreenTouch:
		if event.pressed and held_piece == null and _contains(event.position):
			_pick_up(event)
		elif not event.pressed and held_piece == self and event.index == touch_index:
			_drop()

	# Finger moving
	elif event is InputEventScreenDrag and held_piece == self and event.index == touch_index:
		global_position = event.position + grab_offset


func _pick_up(event: InputEventScreenTouch) -> void:
	held_piece = self
	touch_index = event.index
	grab_offset = global_position - event.position
	scale = Vector2(1.1, 1.1)  # grow a little while held
	z_index = 10               # draw above other pieces
	get_viewport().set_input_as_handled()


func _drop() -> void:
	held_piece = null
	touch_index = -1
	scale = Vector2.ONE
	z_index = 0
