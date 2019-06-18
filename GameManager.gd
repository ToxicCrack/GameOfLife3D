extends Node

var map:GridMap = null
var isRunning = false
var tick = 1.0 #secs
var tickEl = 0.0
var currentLayer = 0.0
var generation = 0

var mode = "3D"

signal on_tick
var cam_init_pos = Vector3()

func _ready():
  self.map = get_tree().get_nodes_in_group("map")[0]
  self.cam_init_pos = get_tree().get_nodes_in_group("camera")[0].translation


func _process(delta):
  if(isRunning):
    self.tickEl += delta
    if(self.tickEl >= self.tick):
      self.tickEl = 0.0
      self.checkCurrentLayer()
      if(self.mode != "2D"):
        self.currentLayer += 1
      self.generation += 1
      emit_signal("on_tick")

func start():
  self.isRunning = true
  
func stop():
  self.isRunning = false
  
func clear():
  self.map.clear()
  self.currentLayer = 0
  self.generation = 0
  get_tree().get_nodes_in_group("camera")[0].translation = self.cam_init_pos
  get_tree().get_nodes_in_group("camera")[0].look_at(Vector3(0,0,0), Vector3(0,1,0))
  
func checkCurrentLayer():
  var cellsToAdd = []
  if(self.mode == "2D"):
    self.currentLayer = 0
    
  for cell in self.map.get_used_cells():
    if(cell.y == self.currentLayer):
      var livingNeighbours = 0
      
      var cellsAround = [
        Vector3(cell.x-1, self.currentLayer, cell.z-1), 
        Vector3(cell.x-1, self.currentLayer, cell.z), 
        Vector3(cell.x-1, self.currentLayer, cell.z+1),
        
        Vector3(cell.x, self.currentLayer, cell.z-1),
        Vector3(cell.x, self.currentLayer, cell.z+1),
        
        Vector3(cell.x+1, self.currentLayer, cell.z-1),
        Vector3(cell.x+1, self.currentLayer, cell.z),
        Vector3(cell.x+1, self.currentLayer, cell.z+1)
      ]
      
      for cellAround in cellsAround:
        if(self.map.get_cell_item(cellAround.x, cellAround.y, cellAround.z) != GridMap.INVALID_CELL_ITEM):
          livingNeighbours += 1
          
      if(livingNeighbours == 2 or livingNeighbours == 3):
        #survived
        cellsToAdd.append([cell.x, self.currentLayer+1, cell.z, 0])
        
        
      
      for cellAround in cellsAround:
        livingNeighbours = 0
        if(self.map.get_cell_item(cellAround.x, cellAround.y, cellAround.z) == GridMap.INVALID_CELL_ITEM):
          var cellsAround2 = [
            Vector3(cellAround.x-1, self.currentLayer, cellAround.z-1), 
            Vector3(cellAround.x-1, self.currentLayer, cellAround.z), 
            Vector3(cellAround.x-1, self.currentLayer, cellAround.z+1),
            
            Vector3(cellAround.x, self.currentLayer, cellAround.z-1),
            Vector3(cellAround.x, self.currentLayer, cellAround.z+1),
            
            Vector3(cellAround.x+1, self.currentLayer, cellAround.z-1),
            Vector3(cellAround.x+1, self.currentLayer, cellAround.z),
            Vector3(cellAround.x+1, self.currentLayer, cellAround.z+1)
          ]
          for cellAround2 in cellsAround2:
            if(self.map.get_cell_item(cellAround2.x, cellAround2.y, cellAround2.z) != GridMap.INVALID_CELL_ITEM):
              livingNeighbours += 1
              
          if(livingNeighbours == 3):
            #birth
            cellsToAdd.append([cellAround.x, self.currentLayer+1, cellAround.z, 1])
            
  #if(cellsToAdd.size() > 0):
  if(self.mode == "2D"):
    self.map.clear()
    for cellToAdd in cellsToAdd:
      self.map.set_cell_item(cellToAdd[0], 0, cellToAdd[2], cellToAdd[3])
  else:
    for cellToAdd in cellsToAdd:
      self.map.set_cell_item(cellToAdd[0], cellToAdd[1], cellToAdd[2], cellToAdd[3])
            

func load_pattern(pattern:Array):
  self.map.clear()
  var lineNum = 0
  var rowNum = 0
  for line in pattern:
    for row in line:
      if(row):
        self.map.set_cell_item(lineNum, 0, rowNum, 0)
      rowNum += 1
    rowNum = 0
    lineNum += 1
      
    
func populate_at(pos):
  if(!self.isRunning):
    pos.y = self.currentLayer
    var map_pos = self.map.world_to_map(pos)
    if(self.map.get_cell_item(map_pos.x, map_pos.y, map_pos.z) != GridMap.INVALID_CELL_ITEM):
      self.map.set_cell_item(map_pos.x, map_pos.y, map_pos.z, -1)
    else:
      self.map.set_cell_item(map_pos.x, map_pos.y, map_pos.z, 0)