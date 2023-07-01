PVector[][] grid;//stores points found so far
ArrayList<QuadTree> activeCells;//stores activeCells (1 QuadTree element for each grid as specified in the paper)
int numActive;//number of active cells
int rad;
int cellSize, initCellSize;
float EPSILON = 10e-12;
ArrayList<PVector> MPS(int radius){//returns all points in sample
  rad = radius;
  initCellSize = (int) (rad / sqrt(2));
  cellSize = initCellSize;
  grid = new PVector[width/initCellSize+1][height/initCellSize+1];
  numActive = grid.length*grid[0].length;
	//initialize quadTree
  activeCells = new ArrayList<QuadTree>();
  for(int i = 0; i < grid.length; i++)
    for(int j = 0; j < grid[0].length; j++)
      activeCells.add(new QuadTree(new PVector(i*initCellSize,j*initCellSize)));
  //start of main algorithm
  int i = 0;
  while(numActive > 0){
    throwDarts(0.4);//multiplier for how many misses must occur before darts stop being thrown
    if(cellSize < EPSILON)//need to break before total loss in precision
      break;
    //subdivide cells
    cellSize /= 2;
    numActive = 0;//recalculate the number of active cells
    for(int j = 0; j < activeCells.size(); j++){
      activeCells.get(j).split();
      numActive += activeCells.get(j).size();
      if(activeCells.get(j).size() == 0)//no longer an active cell
        activeCells.remove(j--);
    }   
  }
	//add all found points to an arrayList
	ArrayList<PVector> ret = new ArrayList<PVector>();
  for(i = 0; i < grid.length; i++)
    for(int j = 0; j < grid[0].length; j++)
      if(grid[i][j] != null)
        if(grid[i][j].x > i*initCellSize && grid[i][j].y > j*initCellSize && grid[i][j].x < (i+1)*initCellSize && grid[i][j].y < (j+1)*initCellSize)
          ret.add(new PVector(grid[i][j].x, grid[i][j].y));
	return ret;
}

void throwDarts(float a){
  int misses = 0;
  int originalNumActive = numActive;
  while(misses < originalNumActive*a){
    //chose cell to throw a dart
    int rand = (int)random(numActive), idx = 0;
    if(activeCells.size() == 0) //if done with algorithm
      break;
    while(rand > activeCells.get(idx).size()){//find randomly selected cell using weights based on area (number of cells each quadtree holds)
      rand -= activeCells.get(idx).size();
      idx++;
    }
    int cellIdx = (int)random(activeCells.get(idx).size());//randomly select a cell within the qudtree
    PVector cell = activeCells.get(idx).children.get(cellIdx);//this is the selected cell
    PVector randomPt = new PVector(cell.x + random(cellSize), cell.y + random(cellSize));//getting random pt within the chosen cell
    //see if the dart is a hit or miss
    if(diskFree(randomPt,activeCells.get(idx).xIdx(),activeCells.get(idx).yIdx())){
      grid[activeCells.get(idx).xIdx()][activeCells.get(idx).yIdx()] = randomPt;
      numActive -= activeCells.get(idx).size();
      activeCells.remove(idx);//entire cell can be removed
    }
    else{
      misses++;
    }
  }
}

float distance(float x1, float x2, float y1, float y2){
  return sqrt(pow(abs(x1 - x2),2) + pow(abs(y1 - y2),2));
}

boolean diskFree(PVector pt, int xIdx, int yIdx){//indicies of square of interest
  //only check close by disks
  for(int i = max(xIdx - 3,0); i < min(xIdx + 3, grid.length); i++){//max and min functions prevent going out of bounds
    for(int j = max(yIdx - 3,0); j < min(yIdx + 3, grid[0].length); j++){
      if(grid[i][j] != null){
        if(distance(grid[i][j].x,pt.x,grid[i][j].y,pt.y) < rad){//comparison between chosen point and a previous point on the grid
          return false;
        }
      }
    }
  }
  return true;
}

boolean filled(PVector pt, int xIdx, int yIdx){//returns true if a cell is filled
  //see if any close circle hits all 4 corners of the square
  for(int i = max(xIdx - 3,0); i < min(xIdx + 3, grid.length); i++){
    for(int j = max(yIdx - 3,0); j < min(yIdx + 3, grid[0].length); j++){
      if(grid[i][j] != null){
        if(distance(grid[i][j].x,pt.x,grid[i][j].y,pt.y) < rad && distance(grid[i][j].x,pt.x+cellSize,grid[i][j].y,pt.y) < rad && distance(grid[i][j].x,pt.x,grid[i][j].y,pt.y+cellSize) < rad && distance(grid[i][j].x,pt.x+cellSize,grid[i][j].y,pt.y+cellSize) < rad){
          return true;
        }
      }
    }
  }
  return false;
}

class QuadTree{//one quadtree for each cell, stores active cells
  ArrayList<PVector> children;//holds the top left point of all active cells of the quadtree 
  PVector location;//top left corner of this quadtree
  QuadTree(PVector topLeft){
    location = new PVector(topLeft.x,topLeft.y);
    children = new ArrayList<PVector>();
    children.add(new PVector(topLeft.x,topLeft.y));
  }
  void split(){
    for(int i = children.size() - 1; i >= 0; i--){//for each child, split into four quadrants
      PVector curr = children.get(i);
      if(!filled(new PVector(curr.x,curr.y),this.xIdx(),this.yIdx()))//top left quadrant of previous cell is not filled by a single circle
        children.add(new PVector(curr.x,curr.y));
      if(!filled(new PVector(curr.x+cellSize,curr.y),this.xIdx(),this.yIdx()))//top right
        children.add(new PVector(curr.x+cellSize,curr.y));
      if(!filled(new PVector(curr.x,curr.y+cellSize),this.xIdx(),this.yIdx()))//bottom left
        children.add(new PVector(curr.x,curr.y+cellSize));
      if(!filled(new PVector(curr.x+cellSize,curr.y+cellSize),this.xIdx(),this.yIdx()))//bottom right
        children.add(new PVector(curr.x+cellSize,curr.y+cellSize));
      children.remove(i);//remove the cell that has been examined (as all cells must have the same size after the split, so this cell's size is too large)
    }
  }
  int size(){
      return children.size();
  }
  int xIdx(){
    return (int)(location.x / initCellSize + 0.5);
  }
  int yIdx(){
    return (int)(location.y / initCellSize + 0.5);
  }
}