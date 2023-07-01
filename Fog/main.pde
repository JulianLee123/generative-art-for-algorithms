/*
Concept:
Visualization of Mohamed S. Ebeida's Maximal Poisson-Disk Sampling algorithm in two dimensions. Selected points are stored in a grid, and active cells are stored as children of
a "flat quadtree". There is a vector for these "quadtrees", 1 for each square in the original grid so that the entire quadtree can be removed if a point is selected within it.
As all active cells are the same size, these cells are simply stored as PVectors. Active cells split at each itteration after a sufficient number of misses. To determine
if one of these cells resulting from the split is active, the algorithm checks if a single circle passes through all four corners. Only nearby circles are examined when testing if point(s) lie within a circle,
and the algorithm terminates if there are no more active cells or if the cell size is less than the precision of the floating point. 
A weighted probability is used when picking a flat quadtree to throw a dart to ensure complete randomness.

I thought the output of the algorithm would be useful to create some type of texture, so after experimenting with different ways to manipulate the points to create a background, I decided to
create layers of "fog" by drawing translucent circles with a small radius whose centers were based of the output from the algorithm. Objects could be drawn between layers of fog to
make these objects seem more distant in an image. I applied this concept with a "city landscape" at night where closer buildings, which were lower in the y-positions of their bottom edges,
would be covered in less layers of fog than farther buildings. Lights for the windows of the buildings are generated at random (based on windowProbability), and the positions of the buildings
also change with every piece. One of 2 color options is randomly chosen for every piece. 
*/

int radius = 20;
float windowProbability = 0.3;
boolean color = false;//color option (2) chosen at random by program

void setup() {
  size(800,600);
  background(0);
	if(random(1) < 0.5)
		color = true;
}

void draw() {
	for(int y = 300; y < height; y += 40 + random(10) - 5){//bottom y coordinate of each row of buildings: this loop runs for each row of buildings
    for(int x = 10; x < width - 10; x += 30 + random(20) - 20){//top left corner, the value added to x creates a gap between buildings
      if(y > height - 50)
        y = height - 5;//make sure we get a row of buildings at the bottom of the screen
      int h, w = 60 + (int)random(20) - 10;//height and width of the building
      if(random(1) < 0.6)//short building
        h = 100 + (int)random(70) - 35;
      else//tall building
        h = 200 + (int)random(100) - 35;
      if(h < w)//make sure the building is taller than it is wide
        h = w + 10;
      if(h > height - 10)//stop building from going above the top edge of the screen
        h = height - 10;
      generateBuilding(x,x+w,y - h, y);
      x += w;          
    }
		fill(50,255);
  	rect(0,y,width,height-y);//adds dark rectangle under the current row of buildings as "flooring"
    fog(radius);//fog created by the mps algorithm 
  }
	fog(radius);
  filter(BLUR, 1);//filter to further the fog effect
  noLoop();
}


