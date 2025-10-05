extends Resource
class_name armas

#propriedades gerais
@export var nome_item: String
@export var imagem: Texture2D
@export var alcance: int
@export var audio_impacto: AudioStreamMP3
@export var velocidade_ataque: float
@export var impacto: float 
@export var tipo: tipoarma
enum tipoarma {
	CORPO_A_CORPO,
	ARMA_DE_FOGO,
	ARREMESSAVEL,
	CONSUMIVEL,
	ITEM_DE_CRAFT
}

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
	if tipo == 1: #ARMA DE FOGO
		if alvo != null:
			var part = preload("res://tscn/particula_sangue.tscn").instantiate()
			part.top_level = true
			part.position = alvo.position
			part.emitting = true
			
			if qntatual == 0:
				recarregar()

			if semiauto == true and aux == true and qntatual >= 1:
				qntatual -= 1
				alvo.add_child(part)
				print("atirou semi, munição atual: ", qntatual)
				aux = false
				if alvo.is_in_group("Inimigo"):
					alvo.vida -= dano
				return

			if semiauto == false and aux == true and qntatual >= 1:
				qntatual -= 1
				alvo.add_child(part)
				print("atirou auto, ", qntatual)
				if alvo.is_in_group("Inimigo"):
					alvo.vida -= dano
				return dano

			if qntatual == 0 and qntreserva == 0:
				print("sem munição")
				return
		else: 
			return
	if tipo == 2: #ARREMESSAVEL
		pass
	
	if tipo == 3: #CONSUMIVEL
		pass

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
