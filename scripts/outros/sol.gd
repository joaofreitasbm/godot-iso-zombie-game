extends Node

#
#@export var duracao_dia: float = 1000.0 # duração de um "dia" no jogo
#
#var hora: float = 0.0 
#
#func _process(delta: float) -> void:
	## avança o tempo de acordo com o delta e duração configurada
	#hora = fmod(hora + delta / duracao_dia, 1.0)
	#
	## converte o tempo em ângulo de rotação (360 graus = 1 ciclo)
	#var rotation_x = lerp(-90.0, 270.0, hora) # começa abaixo do horizonte e gira até acima
	#self.rotation.x = rotation_x
