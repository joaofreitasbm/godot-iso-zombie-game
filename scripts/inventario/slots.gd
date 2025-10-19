extends Button

@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers")
@onready var UI: Control = get_tree().get_root().get_node("main/pers/UI")
var skip: bool = false
var slotvazio: Resource = preload("res://pngs/vazio.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var hotkeys = {
		"primaria": {"texto": "", "tamanho": Vector2(60, 60)},
		"secundaria": {"texto": "Q", "tamanho": Vector2(50, 50)},
		"hotkey1": {"texto": "1", "tamanho": Vector2(50, 50)},
		"hotkey2": {"texto": "2", "tamanho": Vector2(50, 50)},
		"hotkey3": {"texto": "3", "tamanho": Vector2(50, 50)},
		"hotkey4": {"texto": "4", "tamanho": Vector2(50, 50)},
		"hotkey5": {"texto": "5", "tamanho": Vector2(50, 50)},
		"hotkey6": {"texto": "6", "tamanho": Vector2(50, 50)},
	}

	if hotkeys.has(name):
		var config = hotkeys[name]
		$nome_hotkey.text = config.texto
		$imagem.size = config.tamanho

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !skip:
		if pers.arma_atual != null and pers.arma_atual == pers.slots[str(self.name)] and pers.arma_atual == pers.slots["primaria"]:
			$ColorRect.show()
		else:
			$ColorRect.hide()
			
		for x in pers.slots:
			if x == str(self.name) and pers.slots[x] == null:
				$Label.text = ""
				$imagem.texture = slotvazio
				
				
			if x == str(self.name) and pers.slots[x] != null:
				$imagem.texture = pers.slots[x].imagem
				if pers.slots[x].tipo == "Armas":
					$Label.text = str(pers.slots[x].qntatual)
	skip = true
