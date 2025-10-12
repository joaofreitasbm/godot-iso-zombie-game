extends Button

@export var item: itens
@onready var pers: CharacterBody3D = $"../../../.."

@onready var slot = int(self.name) - 1
var slotvazio: Resource = preload("res://pngs/vazio.png")

func _ready() -> void:
	$nome_slot.text = self.name

func _process(_delta: float) -> void:
	
	if pers.hotkey == slot and pers.equipado == true:
		$ColorRect.show()
	else: 
		$ColorRect.hide()
	
	
	if item == null:
		icon = slotvazio
		$quantidade.text = ""
		return
	
	
	if item != null:
		icon = item.imagem

	if item.tipo == "Arma de fogo": # arma de fogo
		$quantidade.text = str(item.qntatual, "/", item.municao)
	elif item.tipo == "Consumivel": # consumível
		$quantidade.text = str(item.quantidade)
	else:
		$quantidade.text = ""


func _on_pressed() -> void:
	var index = get_index()
	pers.hotkey = index
	print("Selecionou slot ", index)
	
func limpar():
	item = null
	$quantidade.text = ""
	icon = null
