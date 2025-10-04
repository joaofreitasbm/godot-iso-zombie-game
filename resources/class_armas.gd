extends Resource
class_name armas

#propriedades gerais
@export var nome_item: String
@export var imagem: Texture2D
@export var dps: float
@export var alcance: int
@export var velocidade_ataque: float
@export var tempocarregamento: float
@export var impacto: float 
@export var tipo: tipoarma
enum tipoarma {
	CORPO_A_CORPO,
	ARMA_DE_FOGO
}

#propriedades armas corpo a corpo
@export var durabilidade: int
@export var audio_impacto: AudioEffect

#propriedades armas de fogo
@export var pente: int
@export var municao_atual: int
@export var municao_reserva: int
@export var semiauto: bool
@export var dano: int
@export var aux = true


func atirar(alvo): #, pers):
	if municao_atual == 0 and tipo == 1:
		recarregar()

	if semiauto == true and aux == true and tipo == 1 and municao_atual >= 1 and alvo != null:
		municao_atual -= 1
		print("atirou semi, munição atual: ", municao_atual)
		aux = false
		if alvo.is_in_group("Inimigo"):
			alvo.vida -= dano
			var part = preload("res://tscn/particula_sangue.tscn").instantiate()
			part.top_level = true
			print(part.position," ", alvo.position)
			part.position = alvo.position
			print(part.position)
			part.emitting = true
			alvo.add_child(part)
		return

	if semiauto == false and aux == true and tipo == 1 and municao_atual >= 1 and alvo != null:
		municao_atual -= 1
		print("atirou auto, ", municao_atual)
		if alvo.is_in_group("Inimigo"):
			alvo.vida -= dano
		return dano

	if municao_atual == 0 and municao_reserva == 0:
		print("sem munição")
		return


func recarregar():
	var x = pente - municao_atual
	if municao_reserva > x:
		municao_reserva -= x
		municao_atual = pente
	elif municao_reserva <= x:
		municao_atual += municao_reserva
		municao_reserva = 0
	else:
		return
