extends Spatial
const RAY_LENGTH = 2000.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
  $Camera.look_at(Vector3(0,0,0), Vector3(0,1,0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if($HUD/HBoxContainer.visible and !GameManager.isRunning):
    var mouse_pos = get_viewport().get_mouse_position()
    var ray_from = $Camera.project_ray_origin(mouse_pos)
    var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * RAY_LENGTH
    
    var result = get_world().direct_space_state.intersect_ray(ray_from, ray_to, [self])
    if(!result.empty()):
      $Box.visible = true
      result.position.y = GameManager.currentLayer
      var grid_pos = GameManager.map.world_to_map(result.position)
      $Box.translation = GameManager.map.map_to_world(grid_pos.x, grid_pos.y, grid_pos.z)
  elif($Box.visible):
    $Box.visible = false

    
func _input(event):
  if event.is_action_pressed("right_mouse") && $HUD/HBoxContainer/StartButton.visible:
    var mouse_pos = get_viewport().get_mouse_position()
    var ray_from = $Camera.project_ray_origin(mouse_pos)
    var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * RAY_LENGTH
    
    var result = get_world().direct_space_state.intersect_ray(ray_from, ray_to, [self])
    if(!result.empty()):
      GameManager.populate_at(result.position)