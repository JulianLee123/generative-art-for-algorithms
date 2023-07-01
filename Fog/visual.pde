void generateBuilding(float x1, float x2, float y1, float y2){
  noStroke();
  int w = int(x2 - x1), h = int(y2 - y1), border = 4;
	//black rectangle represents the building
  fill(50+(int)random(20));
  rect(x1-border,y1-border,w+border*2, h+border*2);
	//calculate the number of x and y windows to be displayed on the building (with some randomness)
  float numXWindow = w/7 + (int)random(5) - 2, numYWindow = h/7 + (int)random(5) - 2, windowW = ((w - numXWindow*(border-1))/numXWindow), windowH = ((h - numYWindow*(border-1))/numYWindow);
  fill(255,255,153);
  for(float i = x1; i < x2 - border; i+= border + windowW){
    for(float j = y1; j < y2 - border; j+= border + windowH){
			//only display some windows based on windowProbability
      if(random(1) < windowProbability)
        rect(i,j,windowW,windowH);
    }
  }
}


void fog(int rad){
	//get points from MPS
	ArrayList<PVector> pts = MPS(rad);
	noStroke();
  if(color)//shows fog as tinted purple to give a nightime feel
    fill(225,225,255,5);
  else
    fill(255,10);
	for(PVector pt : pts)//display points
		ellipse(pt.x, pt.y, rad*3, rad*3);
}