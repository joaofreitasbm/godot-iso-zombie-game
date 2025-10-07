extends CharacterBody3D

var velocidade = 2.0 #randf_range(2.0, 6.0) # velocidade linear entre 2 e 6
var vida = 999#randi_range(70, 140)
var area = false
var body
@onready var stencil = false
@onready var pers = get_node("/root/main/pers")
@onready var gamemode = get_node("/root/main/spawn inimigo")


func _physics_process(delta: float) -> void:
	#$Label.text = str($Timer.time_left, $Timer.is_stopped(), area)

	
	if area == true and $Timer.is_stopped():
			pers.vida += randi_range(-10, -40)
			print(pers.vida)
			$Timer.wait_time = 1
			$Timer.start()
	
	
	
	if not is_on_floor(): 
		velocity += get_gravity() * delta
		
	if vida <= 0:
		print("Inimigo morreu")
		gamemode.inimrestantes -= 1
		queue_free()

	# direção até o jogador
	var direcao = (pers.position - position).normalized()
	
	# aplica velocidade linear constante
	velocity.x = direcao.x * velocidade
	velocity.z = direcao.z * velocidade
	
	# mantém gravidade no eixo Y
	look_at(Vector3(pers.position.x, position.y, pers.position.z), Vector3.UP)

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


func _atacar_pers(body: Node3D) -> void:
	if body.is_in_group("Player"):
		area = true


func _parar_de_atacar(body: Node3D) -> void:
	area = false
