extends Node3D

#@onready var pers = self.get_parent()
#
#@onready var camfrente: Camera3D = $cont_camfrente/viewport_camfrente/camfrente
#@onready var camfundo: Camera3D = $cont_camfundo/viewport_camfundo/camfundo
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#redimensionar()
	#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#
	#camfundo.global_transform = $".".global_transform
	#camfrente.global_transform = $".".global_transform
	#
#func redimensionar():
	#$cont_camfundo/viewport_camfundo.size = DisplayServer.window_get_size()
	#$cont_camfrente/viewport_camfrente.size = DisplayServer.window_get_size()
