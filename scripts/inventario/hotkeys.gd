extends Button

@export var item: Resource
@onready var pers = $"../../../.."

@onready var slot = int(self.name) - 1
var slotvazio = preload("res://pngs/vazio.png")
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
		$quantidade.text = str(item.qntatual, "/", item.qntreserva)
	elif item.tipo == "Consumivel": # consumível
		$quantidade.text = str(item.qntreserva)
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
