# piece.gd
# A puzzle piece the player can drag with a finger.
# Dropped near its target -> snaps in and locks.
# Dropped anywhere else   -> slides back to where it started.

@tool  # also runs in the editor, so the square is visible while building
extends Node2D


# Sent when this piece snaps into its target (used later for "level complete").
signal placed

# Shared by ALL pieces: the piece being held right now (null = none).
# Ensures only one piece can be moved at a time.
static var held_piece: Node2D = null

# Square size in pixels (editable in the Inspector).
@export var size := Vector2(200, 200):
	set(value):
		size = value
		queue_redraw()  # redraw when changed

# Square colour (editable in the Inspector).
@export var color := Color.ORANGE:
	set(value):
		color = value
		queue_redraw()

# The outline this piece belongs to (pick it in the Inspector).
@export var target: Node2D

# How close (in pixels) the piece must be to snap. Bigger = easier.
@export var snap_distance := 80.0

var touch_index := -1            # which finger holds this piece (-1 = none)
var grab_offset := Vector2.ZERO  # finger-to-centre distance, stops jumping
var start_position := Vector2.ZERO  # where to slide back to
var is_placed := false           # true once snapped in (piece is locked)
var tween: Tween                 # current movement animation


func _ready() -> void:
	start_position = global_position  # remember the starting spot


# Draw the square centred on the piece's position.
func _draw() -> void:
	draw_rect(Rect2(-size / 2, size), color)


# True if a screen point is inside this piece.
func _contains(screen_point: Vector2) -> bool:
	return Rect2(-size / 2, size).has_point(to_local(screen_point))


# Handle finger down, move and up.
func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or is_placed:
		return  # ignore input in the editor, or once locked in place

	if event is InputEventScreenTouch:
		# Finger down on this piece, and nothing else is held
		if event.pressed and held_piece == null and _contains(event.position):
			_pick_up(event)
		# Same finger lifted
		elif not event.pressed and held_piece == self and event.index == touch_index:
			_drop()

	# Finger moving while holding this piece
	elif event is InputEventScreenDrag and held_piece == self and event.index == touch_index:
		global_position = event.position + grab_offset


func _pick_up(event: InputEventScreenTouch) -> void:
	if tween:
		tween.kill()  # stop any slide-back animation still running
	held_piece = self
	touch_index = event.index
	grab_offset = global_position - event.position
	scale = Vector2(1.1, 1.1)  # grow slightly while held
	z_index = 10               # draw on top
	get_viewport().set_input_as_handled()  # pieces underneath ignore this touch


func _drop() -> void:
	held_piece = null
	touch_index = -1
	scale = Vector2.ONE
	z_index = 0
			
	# Close enough to the target? Snap. Otherwise slide back.
	if target and global_position.distance_to(target.global_position) <= snap_distance:
		_snap()
	else:
		_return_to_start()


# Move into the target and lock.
func _snap() -> void:
	is_placed = true
	_move_to(target.global_position, 0.15)
	placed.emit()


# Slide gently back to the starting spot.
func _return_to_start() -> void:
	_move_to(start_position, 0.3)


# Smoothly animate to a position over a given time (seconds).
func _move_to(destination: Vector2, duration: float) -> void:
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)  # small bouncy finish
	tween.tween_property(self, "global_position", destination, duration)
