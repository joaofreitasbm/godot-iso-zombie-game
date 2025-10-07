extends Resource
class_name armas

#propriedades gerais
@export var nome_item: String
@export var stack: bool
@export var imagem: Texture2D
@export var alcance: int
@export var audio_impacto: AudioStreamMP3
@export var velocidade_ataque: float
@export var impacto: float 
@export_enum (
	"Corpo a corpo", 
	"Arma de fogo", 
	"Arremessavel",
	"Consumivel",
	"Material") var tipo: String


#propriedades armas corpo a corpo
@export var durabilidade: int

#propriedades armas de fogo
@export var qntmaxima: int
@export var qntatual: int
@export var qntreserva: int
@export var tempocarregamento: float
@export var semiauto: bool
@export var dano: int
@export var aux = true


func usar_equipado(alvo, pers):
	if tipo == "Corpo a corpo": #CORPO A CORPO
		if alvo != null:
			if aux == true and durabilidade >= 1:
				print("bateu com corpo a corpo, durabilidade atual: ", durabilidade)
				aux = false
				if alvo.is_in_group("Inimigo"):
					alvo.vida -= dano
					var part = preload("res://tscn/particula_sangue.tscn").instantiate()
					part.top_level = true
					part.position = alvo.position
					part.emitting = true
					alvo.add_child(part)
					if nome_item != "Mãos livres":
						durabilidade -= 1

	if tipo == "Arma de fogo": #ARMA DE FOGO
		if alvo != null:
			var part = preload("res://tscn/particula_sangue.tscn").instantiate()
			part.top_level = true
			part.position = alvo.position
			part.emitting = true
			
			if qntatual == 0:
				recarregar()

			if semiauto == true and aux == true and qntatual >= 1:
				qntatual -= 1
				print("atirou semi, munição atual: ", qntatual)
				aux = false
				if alvo.is_in_group("Inimigo"):
					alvo.vida -= dano
					alvo.add_child(part)
				return

			if semiauto == false and aux == true and qntatual >= 1:
				qntatual -= 1
				print("atirou auto, ", qntatual)
				if alvo.is_in_group("Inimigo"):
					alvo.vida -= dano
					alvo.add_child(part)
				return 

			if qntatual == 0 and qntreserva == 0:
				print("sem munição")
				return
		else: 
			return

	if tipo == "Arremessavel": #ARREMESSAVEL
		pass
	
	if tipo == "Consumivel": #CONSUMIVEL
		pers.vida += dano
		qntreserva -= 1


func recarregar():
	var x = qntmaxima - qntatual
	if qntreserva > x:
		qntreserva -= x
		qntatual = qntmaxima
	elif qntreserva <= x:
		qntatual += qntreserva
		qntreserva = 0
	else:
		return
