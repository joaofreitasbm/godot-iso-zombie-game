extends CharacterBody3D

var velocidade = 0.1 #randf_range(2.0, 6.0) # velocidade linear entre 2 e 6
var saude = 999#randi_range(70, 140)
var area = false
@onready var stencil = false
@onready var pers = get_node("/root/main/pers")
@onready var gamemode = get_node("/root/main/spawn inimigo")

var direcao: Vector3
var timer_seguir: float

var raio_repulsao: float = 2.0
var forca_repulsao: float = 5.0


var timer_soft_collider: float

func _physics_process(delta: float) -> void:
	timer_soft_collider += delta
	if timer_soft_collider >= 0.1:
		aplicar_soft_collider(delta)
		print("rodou")
		timer_soft_collider = 0
	
	#$Label.text = str($Timer.time_left, $Timer.is_stopped(), area)

	
	if area == true and $Timer.is_stopped():
			pers.saude += randi_range(-10, -40)
			print(pers.saude)
			$Timer.wait_time = 1
			$Timer.start()
	
	
	
	if not is_on_floor(): 
		velocity += get_gravity() * delta
		
	if saude <= 0:
		print("Inimigo morreu")
		gamemode.inimrestantes -= 1
		queue_free()

	# direção até o jogador
	#timer_seguir += delta
	#if timer_seguir >= 1:
		#direcao = (pers.position - position).normalized()
		#timer_seguir = 0
		#print("direção atualizado")
		
	direcao = (pers.position - position).normalized()
	
	# aplica velocidade linear constante
	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade
	
	# mantém gravidade no eixo Y
	look_at(Vector3(pers.position.x, position.y, pers.position.z), Vector3.UP)

	#move_and_slide()
	
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


func _atacar_pers(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true
		

func _parar_de_atacar(_body: Node3D) -> void:
	area = false
	

func aplicar_soft_collider(delta):
	# Pega todos os inimigos na cena (melhor ainda: use get_tree().get_nodes_in_group())
	var inimigos = get_tree().get_nodes_in_group("Inimigo")
	for outro in inimigos:
		if outro == self:
			continue
		
		var dist = global_position.distance_to(outro.global_position)
		
		# Se estiverem muito próximos...
		if dist < raio_repulsao and dist > 0.01: #0.01:
			direcao = (global_position - outro.global_position).normalized()
			var forca = (1.0 - dist / raio_repulsao) * forca_repulsao
			# Move suavemente pra longe
			global_position += direcao * forca * delta
