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
	
	if not is_on_floor(): velocity += get_gravity() * delta
	
	print(stun)
	if not stun:
		var velmax = 3
		var dir = (pers.position - position).normalized() * velmax
		prints("dir", dir)
		velocity.x += dir.x * delta * velmax
		velocity.z += dir.z * delta * velmax
		if velocity.length() > velmax:
			velocity = velocity.normalized() * velmax
		#velocity = velocity.normalized()
		prints("vel", velocity)
		
	if stun:
		var random = randf_range(0.3, 2.0)
		timer_stun += delta
		prints("vel stunado:", velocity)
		if velocity.x > 1 or velocity.z > 1:
			print("DERRUBAR INIMIGO")
		if timer_stun >= random:
			timer_stun = 0
			stun = false

	look_at(pers.position)
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
	


func atualizar_ia():
	
	
	aplicar_soft_collider()


func aplicar_soft_collider():
	for outro in inimigos:
		if outro == self:
			continue
		var offset = global_position - outro.global_position
		var dist2 = offset.length_squared()
		if dist2 < raio_repulsao * raio_repulsao and dist2 > 0.01:
			var dist = sqrt(dist2)
			var push = (1.0 - dist / raio_repulsao) * forca_repulsao
			global_position += offset.normalized() * push * 0.1 # suave, proporcional


func _atacar_pers(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		pers.saude += randi_range(-10, -40)


func _parar_de_atacar(_body: Node3D) -> void:
	area = false
