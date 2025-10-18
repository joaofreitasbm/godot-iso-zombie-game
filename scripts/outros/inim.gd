extends CharacterBody3D

@export var velocidade := 2.0 ## ADICIONAR RANDINT
@export var saude := 999
@export var raio_repulsao := 3.0
@export var forca_repulsao := 5.0
@export var update_rate := 0.2 # tempo entre updates de IA

@onready var stun: bool = false
var timer_stun: float
@onready var stencil: bool = false
@onready var pers := get_node("/root/main/pers")
@onready var gamemode := get_node("/root/main/spawn inimigo")

var area := false
var direcao := Vector3.ZERO
var velocity_y := 0.0
var timer_update := 0.0

# Referência cacheada (não chame get_tree().get_nodes_in_group() sempre)
static var inimigos := []

func _ready() -> void:
	inimigos.append(self)
	set_physics_process(true)

func _exit_tree() -> void:
	inimigos.erase(self)


func _physics_process(delta: float) -> void:
	print(stun)
	if not stun:
		var dir = (pers.position - position).normalized() * 2
		velocity.x = dir.x
		velocity.z = dir.z
		
	if stun:
		timer_stun += delta
		if timer_stun >= 0.5:
			timer_stun = 0
			stun = false
	
	move_and_slide()
	
	if stencil == true:
		for i in self.get_children():
			if i is MeshInstance3D:
				i.mesh.material.stencil_mode = 1 
				i.mesh.material.stencil_color = Color(1,0,0)
				i.mesh.material.stencil_outline_thickness = .1
	if stencil == false:
		for i in self.get_children():
			if i is MeshInstance3D:
				i.mesh.material.stencil_mode = 0
