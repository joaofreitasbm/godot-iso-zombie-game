extends Button

@onready var pers: CharacterBody3D = get_tree().get_root().get_node("main/pers")
@onready var UI: Control = $"../.."
var skip: bool = false
var slotvazio: Resource = preload("res://pngs/vazio.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !skip:

		for x in pers.slots:
			if x == str(self.name) and pers.slots[x] == null:
				#self.icon = slotvazio
				$Label.text = ""
				return
				
			if x == str(self.name) and pers.slots[x] != null:
				self.icon = pers.slots[x].imagem
				if pers.slots[x].tipo == "Arma de fogo":
					$Label.text = str(pers.slots[x].qntatual)
		skip = true
