extends Button

@export var item_slot: Resource
@onready var pers = $"../../.."

@onready var slot = int(self.name) - 1

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if pers.hotkey == slot:
		$ColorRect.show()
	else: 
		$ColorRect.hide()
	
	
	if item_slot == null:
		icon = null
		$quantidade.text = ""
		return

	icon = item_slot.imagem

	if item_slot.tipo == 1: # arma de fogo
		$quantidade.text = str(item_slot.qntatual, "/", item_slot.qntreserva)
	elif item_slot.tipo == 3: # consumível
		$quantidade.text = str(item_slot.qntreserva)
	else:
		$quantidade.text = ""


func _on_pressed() -> void:
	var index = get_index()
	pers.hotkey = index
	print("Selecionou slot ", index)
