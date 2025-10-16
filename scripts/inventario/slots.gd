extends Button

@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers")
@onready var UI: Control = $"../.."
var skip: bool = false
var slotvazio: Resource = preload("res://pngs/vazio.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if self.name == "primaria":
		$nome_hotkey.text = ""
		$imagem.size = Vector2(60, 60)
		return
	if self.name == "secundaria":
		$nome_hotkey.text = "Q"
		$imagem.size = Vector2(50, 50)
		return
	if self.name == "hotkey1":
		$nome_hotkey.text = "1"
		$imagem.size = Vector2(50, 50)
		return
	if self.name == "hotkey2":
		$nome_hotkey.text = "2"
		$imagem.size = Vector2(50, 50)
		return
	if self.name == "hotkey3":
		$nome_hotkey.text = "3"
		$imagem.size = Vector2(50, 50)
		return
	if self.name == "hotkey4":
		$nome_hotkey.text = "4"
		$imagem.size = Vector2(50, 50)
		return
	if self.name == "hotkey5":
		$nome_hotkey.text = "5"
		$imagem.size = Vector2(50, 50)
		return
	if self.name == "hotkey6":
		$nome_hotkey.text = "6"
		$imagem.size = Vector2(50, 50)
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !skip:
		if pers.arma_atual != null and pers.arma_atual == pers.slots[str(self.name)] and pers.arma_atual == pers.slots["primaria"]:
			$ColorRect.show()
		else:
			$ColorRect.hide()
			
		for x in pers.slots:
			if x == str(self.name) and pers.slots[x] == null:
				$Label.text = ""
				$imagem.texture = slotvazio
				return
				
			if x == str(self.name) and pers.slots[x] != null:
				$imagem.texture = pers.slots[x].imagem
				if pers.slots[x].tipo == "Arma de fogo":
					$Label.text = str(pers.slots[x].qntatual)
		skip = true
