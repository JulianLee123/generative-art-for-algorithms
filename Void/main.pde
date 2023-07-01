string dispAlg = 0;//set to 1 to display for k-harmonic means
	
boolean display = true;
float[][][] displayCenters;

int reps = 0;//number of draw loops
int dimensions = 2, numAlgorIt, maxItCount;//maximum number of iterations from a single run
int numPts = 300, numCenters = 15, numIt = 20, numDisplayIt = 5, RADIUS = 285;
float scale;

float[][] centers;
float[][][] allCenters = new float[numIt][numCenters][2];
float[][] realCenters;
float[][] points;
float[][] offset = new float[numPts][2];
float[][] offsetCenters = new float[numCenters][2];
int[] iterationCounts = new int[numIt];
float[] KMPerfs = new float[numIt];

PGraphics img;
int imgLen;

void setup() {
  size(1300,570);
	imgLen = height;
  background(255);
  points = randPointGen(numCenters,numPts/numCenters,400,400,RADIUS);
  img = createGraphics(imgLen, imgLen);
}
void draw() {
  //calculate centers and other values from the algorithm
  for(int reps = 0; reps < 2; reps++){
    numAlgorIt = 0;
    for(int it = 0; it < numIt; it++){
      if(reps == 0)
        centers = KM(points,numCenters);
      else
        centers = KHM(points,numCenters,3.5);
      for(int k = 0; k < centers.length; k++){
        allCenters[it][k][0] = centers[k][0];
        allCenters[it][k][1] = centers[k][1];
      }
      iterationCounts[it] = numAlgorIt;
      KMPerfs[it] = KMPerf(points,centers);
      if(numAlgorIt > maxItCount)
        maxItCount = numAlgorIt;
    }
    iterationCounts = sort(iterationCounts);
    if(reps == 0)
      createImg(true,imgLen,imgLen);
    else
      createImg(false,imgLen,imgLen);
    image(img,reps*(imgLen+10),0);
  }
  noLoop();
}