void polyGen(float x, float y, float rad, int n) {
  float angle = TWO_PI / n;
  img.beginShape();
  for (float i = 0; i < n + 1; i ++) 
    img.vertex(x + cos(angle * i) * rad, y + sin(angle * i) * rad);
  img.endShape();
}

void createImg(boolean needScale, int w, int h){//if scale is true, that means this is the first algorithm to display and the scale needs to be set
  img.beginDraw();
  //get rid of previous image
  img.noStroke();
  img.fill(255);
  img.rect(0,0,w,h);
  //draw background circles (from largest to smallest) based on iteration counts
  //first circle
  img.fill(255-255/iterationCounts.length);
  img.ellipse(w/2,h/2,RADIUS*2*iterationCounts[0]/maxItCount,RADIUS*2*iterationCounts[0]/maxItCount);
  int lastFill = 255-255/iterationCounts.length, thisFill;
  float fillStep;//how much the fill decreases with each iteration
  //create other circles with the fade effect
  for(int i = iterationCounts.length - 2; i >= 0; i--){
    thisFill = 255-255*(iterationCounts.length - i)/iterationCounts.length;
    if(RADIUS*2*iterationCounts[i+1]/maxItCount-RADIUS*2*iterationCounts[i]/maxItCount > 0){
      fillStep = (lastFill - thisFill)/(float)(RADIUS*2*iterationCounts[i+1]/maxItCount-RADIUS*2*iterationCounts[i]/maxItCount);
      for(int r = RADIUS*2*iterationCounts[i+1]/maxItCount, j = 0; r > RADIUS*2*iterationCounts[i]/maxItCount; r--, j++){
        img.fill(lastFill - fillStep*j);
        img.ellipse(w/2,h/2,r,r);
      }
      lastFill = thisFill;
    }
  }
  //calculate points to be displayed based on the deviations of the centers found from the algorithm's runs from the true centers
  float[][] displayPts = new float[numDisplayIt*centers.length][2];
  float minDist = 1000;
  for(int it = 0; it < numDisplayIt; it++){
    for(int c = 0; c < realCenters.length; c++){
      for(int k = 0; k < centers.length; k++){
        float currDist = dis(realCenters[c][0],realCenters[c][1],allCenters[it][k][0],allCenters[it][k][1]);
        if(currDist < minDist){
           minDist = currDist;
           offsetCenters[c][0] = realCenters[c][0] - allCenters[it][k][0];
           offsetCenters[c][1] = realCenters[c][1] - allCenters[it][k][1];
        }
      }
      minDist = 1000;
    }
  }
  if(needScale){
    float maxDist = 0;
    for(int it = 0; it < numDisplayIt; it++)
      for(int c = 0; c < offsetCenters.length; c++)
        if(dis(offsetCenters[c][0],offsetCenters[c][1],0,0) > maxDist)
          maxDist = dis(offsetCenters[c][0],offsetCenters[c][1],0,0);
    scale = (w/2)/maxDist;
  }
  for(int it = 0; it < numDisplayIt; it++){
    for(int c = 0; c < offsetCenters.length; c++){
      displayPts[it*centers.length + c][0] = offsetCenters[c][0]*scale+w/2;
      displayPts[it*centers.length + c][1] = offsetCenters[c][1]*scale+h/2;
    }
  }
  //display line segments based on 
  float meanPerf = 0, stdev = 0;
  for(int i = 0; i < KMPerfs.length; i++)
    meanPerf += KMPerfs[i];
  meanPerf /= KMPerfs.length;
  for(int i = 0; i < KMPerfs.length; i++)
    stdev += pow(abs(KMPerfs[i]-meanPerf),2);
  stdev /= KMPerfs.length;
  stdev = sqrt(stdev);
  img.stroke(0,100);
  img.strokeWeight(1);
  for(int i = 0; i < stdev; i++){
    float angle = random(1)*2*PI;
    float dist = random(1)*w/2;
    float len = random(60)+10;
    img.line(cos(angle)*dist+w/2,sin(angle)*dist+h/2,cos(angle)*(dist+len)+w/2,sin(angle)*(dist+len)+h/2);
  }
  //display points
  img.fill(0,0);
  img.strokeWeight(1);
  for(int i = 0; i < displayPts.length; i++){
    float sideLen = 40*random(1)+10;
    if(random(1) < 0.1)
      sideLen += 60;
    img.stroke(abs(displayPts[i][0]-w/2)*3,dis(displayPts[i][0],displayPts[i][1],w/2,h/2)/3,abs(displayPts[i][1]-h/2)*3);
		float angle = PI/4.0*random(1);
		img.pushMatrix();
		img.translate(displayPts[i][0]-sideLen/2,displayPts[i][1]-sideLen/2);
		img.rotate(angle);
		img.rect(0,0,sideLen,sideLen);
		img.popMatrix();
  }
  img.endDraw();
}