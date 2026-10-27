# target.gd
# The outline (silhouette) a piece must be dropped into.
# For now it's a coloured outline of a square (placeholder art).

@tool  # visible in the editor while building
extends Node2D


# Outline size in pixels (should match its piece).
@export var size := Vector2(200, 200):
	set(value):
		size = value
		queue_redraw()

# Outline colour (World 1 rule: same colour as its piece).
@export var color := Color.ORANGE:
	set(value):
		color = value
		queue_redraw()

# Outline thickness in pixels.
@export var line_width := 8.0:
	set(value):
		line_width = value
		queue_redraw()


# Draw a faint filled square plus a thick border.
func _draw() -> void:
	var rect := Rect2(-size / 2, size)
	draw_rect(rect, Color(color, 0.2))                # light fill
	draw_rect(rect, color, false, line_width)          # border only
