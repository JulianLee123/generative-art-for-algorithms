float dis(float x1, float y1, float x2, float y2){
  return sqrt(pow(abs(y1-y2),2) + pow(abs(x1-x2),2));
}

//generates cluster based on the gaussian distribution given a number of points for the cluster, number of dimensions, and location of the center
//pass in array to add points to, and specify index where to start adding points
void genCluster(int numPts, int dim, float[] center, float[][] pts, int startIdx){
  for(int i = 0; i < numPts; i++)
    for(int d = 0; d < dim; d++)
      pts[startIdx+i][d] = (randomGaussian()*1.4 + center[d])*8;//magnification of points for display: algorithm runs the same
}

void genClusterRand(int numPts, int dim, float[] center, float[][] pts, int startIdx){
  float spread = random(25) + 15;//1 sd
  for(int i = 0; i < numPts; i++)
    for(int d = 0; d < dim; d++){
       pts[startIdx+i][d] = randomGaussian()*spread + center[d];
    }
}

//generates points in 2 dimensions
float[][] randPointGen(int numCenters, int ptsPerCluster, int x, int y, int rad){//the center of all clusters will be within the circle with center x and y and radius rad
  realCenters = new float[numCenters][2];
  float[][] pts = new float[numCenters*ptsPerCluster][2];
  for(int i = 0; i < numCenters; i++){   
    while(true){
      realCenters[i][0] = random(x-rad,x+rad);
      realCenters[i][1] = random(y-rad,y+rad);
      if(dis(realCenters[i][0],realCenters[i][1],x,y) < rad)
        break;
    }
    genClusterRand(ptsPerCluster,2,realCenters[i],pts,i*ptsPerCluster);
  }
  return pts;
}

float[][] pointGen(int r, int c, int ptsPerCluster){//2d
  float[] center = new float[2];
  float[][] pts = new float[r*c*ptsPerCluster][2];
  center[0] = center[1] = 4*sqrt(2);
  for(int i = 0; i < r; i++){
    for(int j = 0; j < c; j++){
      genCluster(ptsPerCluster,2,center,pts,i*ptsPerCluster*c+j*ptsPerCluster);
      center[1] += 4*sqrt(2);
    }
    center[0] += 4*sqrt(2);
    center[1] = 4*sqrt(2);
  }
  return pts;
}

float[][] forgy(float[][] points, int K){
  float[][] centers = new float[K][points[0].length];
  //initialize centers by the forgy method
  boolean[] isCenter = new boolean[points.length];
  for(int i = 0; i < points.length; i++)
    isCenter[i] = false;
  for(int c = 0; c < K; c++){
    int idx = (int)random(points.length);
    while(isCenter[idx])
      idx = (int)random(points.length);
    isCenter[idx] = true;
    //assign center to point
    for(int d = 0; d < points[0].length; d++)
      centers[c][d] = points[idx][d];
  }
  return centers;
}

float[][] randomPartition(float[][] points, int K){//assigns points to clusters randomly and then computes the centroid of each cluster as the centers
  //initialization
  float[][] centers = new float[K][points[0].length];
  int[] numPts = new int[K];//number of points in the given cluster
  for(int c = 0; c < K; c++){
    for(int d = 0; d < points[0].length; d++)
      centers[c][d] = 0;
    numPts[c] = 0;
  }
  //assign points to clusters; centers will be equal to the sum of all points in the given cluster
  for(int i = 0; i < points.length; i++){
    int cluster = (int)random(K);
    numPts[cluster]++;
    for(int d = 0; d < points[0].length; d++)
      centers[cluster][d] += points[i][d];
  }
  for(int c = 0; c < K; c++)
    for(int d = 0; d < points[0].length; d++)
      centers[c][d] /= numPts[c];
  return centers;
}

float[][] randomCenters(int K){//works for 2d: for art purposes
  float[][] centers = new float[K][2];
  for(int c = 0; c < K; c++){
    centers[c][0] = random(100,width-100);
    centers[c][1] = random(100,height-100);
  }
  return centers;
}

float[][] KM(float[][] points, int K){
  int maxIt = 3000;
  float[][] centers = randomPartition(points,K);
  int it = -1;
  while(++it < maxIt){
    int[] pointToCluster = new int[points.length]; //index of the center to which point i is closest to
    int[] pointsPerCluster = new int[K];
    for(int c = 0; c < K; c++)
      pointsPerCluster[c] = 0;
    //assign each point to a center
    for(int i = 0; i < points.length; i++){
      float minDist = 100000;
      for(int c = 0; c < K; c++){
        float currDist = 0;
        for(int d = 0; d < points[0].length; d++){
          currDist += pow(points[i][d] - centers[c][d],2);
        }
        currDist = sqrt(currDist);
        if(minDist > currDist){
          pointToCluster[i] = c;//assign point to center c
          minDist = currDist;
        }
      }
      pointsPerCluster[pointToCluster[i]]++;
    }
    //calculate new centers
    float[][] newCenters = new float[K][points[0].length];
    for(int c = 0; c < K; c++)
      for(int d = 0; d < points[0].length; d++)
        newCenters[c][d] = 0;
    //each center is equal to the sum of all points
    for(int i = 0; i < points.length; i++)
      for(int d = 0; d < points[0].length; d++)
          newCenters[pointToCluster[i]][d] += points[i][d];
    //divide each center by the number of points
    boolean done = true;
    for(int c = 0; c < K; c++)
        for(int d = 0; d < points[0].length; d++){
            newCenters[c][d] /= pointsPerCluster[c];
            if(abs(newCenters[c][d] - centers[c][d]) > 0.001)
              done = false;
        }
    if(done){
      numAlgorIt = it;
      break;
    }
    centers = newCenters;
  }
  //println("Number of Iterations: " + it);
  return centers;
}

/*Assuming there are more points than clusters
  Returns a K by D array where K is the number of clusters and D is the number of dimensions
  Each row in the array represents a point in the D-dimensional space equivalent to the mean 
  of the ith cluster.
  Clusters are formed such that each point belongs to the closest cluster.*/
float[][] KHM(float[][] points, int K, float p){
  int maxIt = 1000;
  float[][] centers = randomPartition(points,K);//forgy(points,K);
  //Initialize variables for main algorithm
  float[][] dist = new float[points.length][K];//dist[a][b] contains the distance between point a and center b
  int[] minIdx = new int[points.length];//dist[a][minIdx[a]] contains the minimum distance between point a and a center
  //intermediaries for harmonic averages calculation
  float[] A = new float[points.length];
  float[][] Q = new float[points.length][K];
  float[] QQ = new float[K];
  float[][] P = new float[points.length][K];
  float[][] oldCenters = new float[K][points[0].length];
  for(int c = 0; c < K; c++)
    for(int d = 0; d < points[0].length; d++)
        oldCenters[c][d] = 0;
  //main loop
  int it = 0;
  for(; it < maxIt; it++){
    //check for convergence
    boolean done = false;
    for(int c = 0; c < K; c++){
      for(int d = 0; d < points[0].length; d++){
        if(abs(centers[c][d] - oldCenters[c][d]) > 0.001){
          c = K;
          break;
        }
      }
      if(c == K - 1)
        done = true;
    }
    if(done){
      break;
    }
    for(int c = 0; c < K; c++)
      for(int d = 0; d < points[0].length; d++){
          oldCenters[c][d] = centers[c][d];
      }
    //reinitialize temporary arrays
    for(int i = 0; i < dist.length; i++){
      minIdx[i] = 0;
      A[i] = 0;
      if(i < K)
        QQ[i] = 0;
      for(int c = 0; c < K; c++){
        Q[i][c] = 0;
        P[i][c] = 0;
        dist[i][c] = 0;
      }
    }
    //update distances
    for(int i = 0; i < dist.length; i++){
      for(int c = 0; c < K; c++){
        for(int d = 0; d < points[0].length; d++){
          dist[i][c] += pow(points[i][d] - centers[c][d],2);
        }
        dist[i][c] = sqrt(dist[i][c]);
        if(dist[i][minIdx[i]] > dist[i][c])
          minIdx[i] = c;
      }
    }
    //compute harmonic averages using formulas provided by B. Zhang. Generalized k-harmonic means – boosting in unsupervised learning. Technical Report HPL-2000-137, Hewlett-Packard Labs, 2000.
    for(int i = 0; i < dist.length; i++)
      for(int c = 0; c < K; c++)
        if(c != minIdx[i])//prevent division by 0
          A[i] += pow(dist[i][minIdx[i]]/dist[i][c],p);
    for(int i = 0; i < dist.length; i++){
      for(int c = 0; c < K; c++){
        Q[i][c] = pow(dist[i][minIdx[i]],p-2)/pow(A[i]+1,2);
        if(c != minIdx[i])//prevent division by 0
          Q[i][c] *= pow(dist[i][minIdx[i]]/dist[i][c],p+2);
      }
    }
    for(int c = 0; c < K; c++)
      for(int i = 0; i < dist.length; i++)
        QQ[c] += Q[i][c];
    for(int i = 0; i < dist.length; i++)
      for(int c = 0; c < K; c++)
        P[i][c] = Q[i][c] / QQ[c];
   for(int c = 0; c < K; c++)
      for(int d = 0; d < points[0].length; d++)
        centers[c][d] = 0;
    for(int c = 0; c < K; c++)
      for(int i = 0; i < dist.length; i++)
        for(int d = 0; d < points[0].length; d++)
          centers[c][d] += P[i][c] * points[i][d];
  }
  //println("Number of Iterations: " + it);
  numAlgorIt = it;
  return centers;
}

float KMPerf(float[][] points, float[][] centers){//measures how well algorithm performed based on KM performance function
    float perfVal = 0;
    for(int i = 0; i < points.length; i++){
      float minDist = 100000;
      for(int c = 0; c < centers.length; c++){
        float currDist = 0;
        for(int d = 0; d < points[0].length; d++){
          currDist += pow(points[i][d] - centers[c][d],2);
        }
        currDist = sqrt(currDist);
        if(minDist > currDist)
          minDist = currDist;
      }
      perfVal += minDist;
    }
    return perfVal;
}