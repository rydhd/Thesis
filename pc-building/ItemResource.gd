# ItemResource.gd
@tool
extends Resource

class_name ItemResource


## The name of the item
@export var item_name: String = "New Item"

## The 2D icon to show in the inventory
@export var item_icon: Texture2D

## The 3D scene to spawn in the world
@export var item_scene: PackedScene
