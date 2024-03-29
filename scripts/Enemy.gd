extends Area2D

signal camera_shake_requested

const explosion_scene = preload("res://scenes/Explosion.tscn")

export var velocity: = Vector2()
export var health: = 0
export var points: = 5


func _ready() -> void:
    # Connect the shake signal to the method in the camera
    connect("camera_shake_requested", Globals.world.get_node("Camera"), "_on_camera_shake_requested")


func _process(delta: float) -> void:
    move(delta)
    check_and_destroy()


func set_health(new_health: int) -> void:
    if is_queued_for_deletion(): return
    health = new_health
    if health <= 0:
        Globals.score += points
        emit_signal("camera_shake_requested")
        create_explosion()
        queue_free()


func move(delta: float) -> void:
    translate(velocity * delta)
    

func create_explosion() -> void:
    var exp_instance = explosion_scene.instance()
    exp_instance.position = position
    Globals.add_child_to_world(exp_instance)


func check_and_destroy() -> void:
    # Checks if the sprite moves offscreen and deletes it if it does
    var sprite_size = $Sprite.texture.get_size().y * $Sprite.scale.y
    if position.y - (sprite_size / 2) >= get_viewport_rect().size.y:
        queue_free()


func _on_Enemy_area_entered(area: Area2D) -> void:
    if area.get_collision_layer_bit(0):  # Player ship
        set_health(0)
        area.queue_free()
    elif area.get_collision_layer_bit(1):  # Player bullet
        $AudioPlayer/OnHit.play()
        set_health(health - 1)
        area.create_flare(true)
        area.queue_free()
