extends CanvasLayer

var presets = [
  {"name": "Presets"},
  {"name": "separator"},
  {"name": "Glider", "pattern": [[0, 1, 0], [0, 0, 1], [1, 1, 1]]},
  {"name": "Light Spaceship", "pattern": [[0, 1, 1, 1, 1], [1, 0, 0, 0, 1], [0, 0, 0, 0, 1], [1, 0, 0, 1, 0]]},
  {"name": "separator"},
  {"name": "Small Exploder", "pattern": [[0, 1, 0], [1, 1, 1], [1, 0, 1], [0, 1, 0]]},
  {"name": "Exploder", "pattern": [[1, 0, 1, 0, 1], [1, 0, 0, 0, 1], [1, 0, 0, 0, 1], [1, 0, 0, 0, 1], [1, 0, 1, 0, 1]]},
  {"name": "10 Cell Row", "pattern": [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]},
  {"name": "Tumbler", "pattern": [[0, 1, 1, 0, 1, 1, 0], [0, 1, 1, 0, 1, 1, 0], [0, 0, 1, 0, 1, 0, 0], [1, 0, 1, 0, 1, 0, 1], [1, 0, 1, 0, 1, 0, 1], [1, 1, 0, 0, 0, 1, 1]]},
  {"name": "separator"},
  {"name": "Acorn", "pattern": [[0, 1], [0, 0, 0, 1], [1, 1, 0, 0, 1, 1, 1]]},
  {"name": "B-Heptomino", "pattern": [[1, 0, 1, 1], [1, 1, 1], [0, 1, 0]]},
  {"name": "Extinction", "pattern": [[1, 1, 1], [1, 0, 1], [1, 0, 1], [0, 0, 0], [1, 0, 1], [1, 0, 1], [1, 1, 1]]},
  {"name": "r-Pentomino", "pattern": [[0, 1, 1], [1, 1, 0], [0, 1, 0]]},
  {"name": "separator"},
]

var cam_start_pos = Vector3(19.677, 12.943, 0.0)
var cam_start_rot = Vector3(-40.976, 90.326, -0.157)
var cam_top_pos = Vector3(0.0, 31.0, 0.0)
var cam_top_rot = Vector3(-90.0, -90.0, 180.0)
var camera:Camera = null

func _ready():
  self.camera = get_tree().get_nodes_in_group("camera")[0]
  self.camera.translation = self.cam_start_pos
  self.camera.rotation_degrees = self.cam_start_rot
  
  $HBoxContainer.visible = false
  $Sidebar.visible = false
  GameManager.connect("on_tick", self, "on_tick")
  self.load_presets()
  #create file if not present
  self.save_presets()
  
  self.refresh_presets()

func refresh_presets():
  $HBoxContainer/OptionButton.clear()
  for preset in presets:
    if(preset["name"] == "separator"):
      $HBoxContainer/OptionButton.add_separator()
    else:
      $HBoxContainer/OptionButton.add_item(preset["name"])

func save_presets():
  var file = File.new()
  file.open("res://presets.cfg", File.WRITE)
  var jsonStr = JSON.print(self.presets)
  jsonStr = jsonStr.replace(":[", ":[\n")
  jsonStr = jsonStr.replace("],", "],\n")
  jsonStr = jsonStr.replace(",{", ",\n{")
  jsonStr = jsonStr.replace("]]", "]\n]")
  jsonStr = jsonStr.replace("}]", "}\n]")
  file.store_string(jsonStr)
  file.close()

func load_presets():
  var file = File.new()
  file.open("res://presets.cfg", File.READ)
  var content = file.get_as_text()
  file.close()
  var result = JSON.parse(content)
  if(result.error == OK):
    self.presets = result.result
  else:
    print("Error parsing presets")

func on_tick():
  $GenerationLabel.text = str(int(GameManager.generation))+"."

func _on_StartButton_pressed():
  if(!GameManager.isRunning):
    GameManager.start()
    $HBoxContainer/StartButton.text = "stop"
  else:
    GameManager.stop()
    $HBoxContainer/StartButton.text = "start"

func _input(event):
  if event.is_action_pressed("ui_cancel"):
    $HBoxContainer.visible = !$HBoxContainer.visible
    $Sidebar.visible = !$Sidebar.visible
    
func _on_ClearButton_pressed():
  GameManager.clear()
  GameManager.stop()
  $HBoxContainer/StartButton.text = "start"

func _on_OptionButton_item_selected(ID):
  var preset = self.presets[ID]
  if(preset.has("pattern") and preset["pattern"].size() > 0):
    GameManager.load_pattern(preset["pattern"])

func _on_speedSlider_value_changed(value):
  GameManager.tick = value

func _on_2DModeCheckbox_toggled(button_pressed):
  if(button_pressed):
    GameManager.mode = "2D"
  else:
    GameManager.mode = "3D"


func _on_presetSaveButton_pressed():
  if($HBoxContainer/presetSaveName.text == ""):
    $AcceptDialog.dialog_text = tr("Please enter a preset name.")
    $AcceptDialog.popup()
    return
  
  self.save_as_preset($HBoxContainer/presetSaveName.text)
  $AcceptDialog.dialog_text = ""
  
func save_as_preset(preset_name):
  var max_x = 0
  var max_z = 0
  var min_x = 0
  var min_z = 0
  for cell in GameManager.map.get_used_cells():
    if(cell.y != 0): continue
    if(max_x == 0 or max_x < cell.x):
      max_x = cell.x
    if(max_z == 0 or max_z < cell.z):
      max_z = cell.z
      
    if(min_x == 0 or min_x > cell.x):
      min_x = cell.x
    if(min_z == 0 or min_z > cell.z):
      min_z = cell.z
  
  var pattern = []
  for line in range(min_x, max_x+1):
    var lineArr = []
    for row in range(min_z, max_z+1):
      var cellAlive = 0
      for cell in GameManager.map.get_used_cells():
        if(cell.y != 0): continue
        if(cell.x == line && cell.z == row):
          cellAlive = 1
      
      lineArr.append(cellAlive)
    pattern.append(lineArr)
  
  self.presets.append({"name": preset_name, "pattern": pattern})
  self.save_presets()
  
  self.refresh_presets()
  
  $AcceptDialog.dialog_text = tr("Preset saved.")
  $AcceptDialog.popup()
      

func _on_CameraTopButton_pressed():
  self.camera.translation = self.cam_top_pos
  self.camera.rotation_degrees = self.cam_top_rot


