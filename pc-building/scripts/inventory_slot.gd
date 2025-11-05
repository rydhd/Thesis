# InventorySlot.gd
extends Panel

@export var item: ItemResource
@onready var icon_rect: TextureRect = $TextureRect

func _ready():
	if item and item.item_icon:
		icon_rect.texture = item.item_icon

func _get_drag_data(at_position: Vector2) -> Variant:
	print("DRAG STARTED!") # <-- ADD THIS LINE
	
	if not item:
		print("Drag failed: Slot has no item resource.")
		return null
		
	var preview = TextureRect.new()
	preview.texture = item.item_icon
	preview.size = Vector2(64, 64)
	set_drag_preview(preview)
	
	return item
