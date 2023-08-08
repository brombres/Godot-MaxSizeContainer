# Made by Matthieu Huvé
# Ported for Godot 4 Beta 10 by Benedikt Wicklein
# Updated for Godot 4.x by Brom Bresenham (tested on Godot 4.2-dev2)

## Limits the size of its single child node to arbitrary dimensions.
@tool
class_name MaxSizeContainer
extends MarginContainer

# Enums
enum {LEFT, RIGHT, TOP, BOTTOM}

enum VERTICAL_ALIGN
{
	TOP,    ## Align with the top side of this MaxSizeContainer.
	CENTER, ## Center vertically within this MaxSizeContainer.
	BOTTOM  ## Align with the bottom side of this MaxSizeContainer.
}

enum HORIZONTAL_ALIGN
{
	LEFT,   ## Align with the left side of this MaxSizeContainer.
	CENTER, ## Center horizontally within this MaxSizeContainer.
	RIGHT   ## Align with the right side of this MaxSizeContainer.
}

# Parameters
## The maximum size the child node is allowed to be, or '-1' for no limit.
@export var max_size := Vector2(-1, -1):
	set(value):
		if value.x < 0:
			value.x = -1
		if value.y < 0:
			value.y = -1

		max_size = value
		if is_initialized:
			_check_if_valid()
			_adapt_margins()

## How the child node is vertically aligned within the excess space once it has reached its maximum height.
@export var valign := VERTICAL_ALIGN.CENTER:
	set(value):
		valign = value
		if is_initialized:
			_adapt_margins()

## How the child node is horizontally aligned within the excess space once it has reached its maximum width.
@export var halign := HORIZONTAL_ALIGN.CENTER:
	set(value):
		halign = value

		if is_initialized:
			_adapt_margins()

# child node of the container
var child : Node

# Intern var
var minimum_child_size : Vector2
var is_size_valid := {"x": false, "y": false}
var is_initialized := false

var is_resizing := false # infinite recursion guard

func _ready() -> void:
	# Reset custom margins if modified from the editor
	_set_custom_margins(LEFT, 0)
	_set_custom_margins(RIGHT, 0)
	_set_custom_margins(TOP, 0)
	_set_custom_margins(BOTTOM, 0)

	# Sets up the Container
	resized.connect(_on_self_resized)

	child_entered_tree.connect( _on_child_entered_tree )
	child_exiting_tree.connect( _on_child_exiting_tree )

	if get_child_count() > 0:
		_initialize(get_child(0))

func _initialize(p_child: Node) -> void:
	# Sets the child node
	if not p_child: return
	child = p_child
	minimum_child_size = p_child.get_combined_minimum_size()
	p_child.minimum_size_changed.connect( _on_child_minimum_size_changed )

	_check_if_valid()
	_adapt_margins()

	# Tells other parts that the child node is ready
	# important to avoid early calculations that give wrong minimum child size
	is_initialized = true

func _check_if_valid() -> void:
	# This function checks if the child is smaller than max_size.
	# Otherwise there would be a risk of infinite margins
	if child == null:
		return

	if max_size.x < 0:
		is_size_valid.x = false
	elif minimum_child_size.x > max_size.x:
		is_size_valid.x = false
		push_warning(str("max_size ( ", max_size, " ) ignored on x axis: too small.",
				"The minimum possible size is: ", minimum_child_size))
	else:
		is_size_valid.x = true

	if max_size.y < 0:
		is_size_valid.y = false
	elif minimum_child_size.y > max_size.y:
		is_size_valid.y = false
		push_warning(str("max_size ( ", max_size, " ) ignored on y axis: too small.",
				"The minimum possible size is: ", minimum_child_size))
	else:
		is_size_valid.y = true


func _adapt_margins() -> void:
	# Adapts the margin to keep the child size below max_size
	var rect_size := size
	# If the container size is smaller than the max size, no margins are necessary
	if rect_size.x < max_size.x:
		_set_custom_margins(LEFT, 0)
		_set_custom_margins(RIGHT, 0)
	if rect_size.y < max_size.y:
		_set_custom_margins(TOP, 0)
		_set_custom_margins(BOTTOM, 0)

	### x ###
	# If the max_size is smaller than the child's size: ignore it
	if not is_size_valid.x:
		_set_custom_margins(LEFT, 0)
		_set_custom_margins(RIGHT, 0)

	# Else, adds margins to keep the child's rect_size below the max_size
	elif rect_size.x >= max_size.x:
		var new_margin_left : int
		var new_margin_right : int

		match halign:
			HORIZONTAL_ALIGN.LEFT:
				new_margin_left = 0
				new_margin_right = int(rect_size.x - max_size.x)
			HORIZONTAL_ALIGN.CENTER:
				new_margin_left = int((rect_size.x - max_size.x) / 2)
				new_margin_right = int((rect_size.x - max_size.x) / 2)
			HORIZONTAL_ALIGN.RIGHT:
				new_margin_left = int(rect_size.x - max_size.x)
				new_margin_right = 0

		_set_custom_margins(LEFT, new_margin_left)
		_set_custom_margins(RIGHT, new_margin_right)

	### y ###
	# If the max_size is smaller than the child's size: ignore it
	if not is_size_valid.y:
		_set_custom_margins(TOP, 0)
		_set_custom_margins(BOTTOM, 0)

	# Else, adds margins to keep the child's rect_size below the max_size
	elif rect_size.y >= max_size.y:
		var new_margin_top : int
		var new_margin_bottom : int

		match valign:
			VERTICAL_ALIGN.TOP:
				new_margin_top = 0
				new_margin_bottom = int(rect_size.y - max_size.y)
			VERTICAL_ALIGN.CENTER:
				new_margin_top = int((rect_size.y - max_size.y) / 2)
				new_margin_bottom = int((rect_size.y - max_size.y) / 2)
			VERTICAL_ALIGN.BOTTOM:
				new_margin_top = int(rect_size.y - max_size.y)
				new_margin_bottom = 0

		_set_custom_margins(TOP, new_margin_top)
		_set_custom_margins(BOTTOM, new_margin_bottom)


func _set_custom_margins(side : int, value : int) -> void:
# This function makes custom constants modifications easier
	match side:
		LEFT:
			#set("custom_constants/margin_left", value)
			add_theme_constant_override("margin_left", value)
		RIGHT:
			#set("custom_constants/margin_right", value)
			add_theme_constant_override("margin_right", value)
		TOP:
			#set("custom_constants/margin_top", value)
			add_theme_constant_override("margin_top", value)
		BOTTOM:
			#set("custom_constants/margin_bottom", value)
			add_theme_constant_override("margin_bottom", value)


func _on_self_resized() -> void:
	# To avoid errors in tool mode and setup, the container must be fully ready
	if is_initialized and not is_resizing:
		is_resizing = true
		_adapt_margins()
		is_resizing = false


func _on_child_entered_tree( p_child:Node ) -> void:
	if get_child_count() == 1:
		_initialize( p_child )
	else:
		push_warning(str("MaxSizeContainer can only handle one child. ", p_child.name,
		" will be ignored because ", get_child(0).name, " is the first child."))

func _on_child_exiting_tree( p_child:Node ) -> void:
	if not p_child == child:
		# Some other child that we're not paying attention to is being removed
		return

	# Stops margin calculations
	is_initialized = false

	# Disconnect signals
	p_child.minimum_size_changed.disconnect( _on_child_minimum_size_changed )
	child = null

	# Reset custom margins
	_set_custom_margins(LEFT, 0)
	_set_custom_margins(RIGHT, 0)
	_set_custom_margins(TOP, 0)
	_set_custom_margins(BOTTOM, 0)

	if get_child_count() > 1:
		# There will still be at least one node remaining. Reinitialize and manage it.
		for i in range( get_child_count() ):
			var cur = get_child(i)
			if cur != p_child:
				_initialize( cur )
				break


func _on_child_minimum_size_changed() -> void:
	minimum_child_size = child.get_combined_minimum_size()
	_check_if_valid()

