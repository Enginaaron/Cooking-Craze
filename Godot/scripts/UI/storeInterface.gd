extends CanvasLayer

@export var option_card_scene: PackedScene  # Assign your ItemCard.tscn here
@onready var moneyLabel = get_tree().get_root().get_node("Node2D/UI/moneyCounter/MoneyLabel")

# Dictionary with keys "sprite", "cost", and "stat_bonus"
var all_items = [
	{ "sprite": preload("res://textures/boots.png"), "cost": 2, "stat_bonus": {"speed": 5} },
	{ "sprite": preload("res://textures/boots.png"), "cost": 5, "stat_bonus": {"ovenSpeed": 10} },
	{ "sprite": preload("res://textures/boots.png"), "cost": 8, "stat_bonus": {"chopSpeed": 3} },
	# Remember to add more items later
]

var stock = [] 
var has_purchased = false

@onready var cards_container = $CardsContainer

func _ready():
	refresh_stock()

func refresh_stock():
	print("refreshed")
	stock.clear()
	has_purchased = false
	# Clear any previous cards
	for n in cards_container.get_children():
		cards_container.remove_child(n)  
		n.queue_free() 
	
	# Randomly pick three items (might complicate it by adding difficulty scaling later)
	var items_pool = all_items.duplicate()
	items_pool.shuffle()
	stock = items_pool.slice(0, 3)
	
	# Create item cards for each stock item
	for item in stock:
		var card = option_card_scene.instantiate()
		card.setup_card(item.sprite, item.cost)
		card.connect("item_selected", Callable(self, "_on_item_selected"))
		cards_container.add_child(card)

func _on_item_selected(cost, stat_bonus):
	if has_purchased:
		return  # Only allow one purchase per shop visit
	
	# Purchase logic
	var money = moneyLabel.get_money()
	if money >= cost:
		money -= cost
		# Apply stat bonus to the player (will do later)
		has_purchased = true
		_disable_remaining_cards()
		self.hide()
		print("Item purchased!")
	else:
		# Optionally, show a "Not enough money" message
		print("Not enough money to purchase that item.")

func _disable_remaining_cards():
	for card in cards_container.get_children():
		card.set_disabled(true)
