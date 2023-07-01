# Void - Piece based on Variations of K-Means

This is a visualization to compare the performance of different variations of k-means (in this case k-means and k-harmonic means). This class of center-based clustering algorithms attempts to locate the centers for the cluster of points associated with each class. To predict the class of a given point, points are assigned to the nearest cluster (by an algorithm-specific distance metric). The visualization is based on the algorithm's performance over n runs. 

Notes on display:
- The neon shapes are based on the center offsets (the offset between the true cluster center and the nearest generated center from the k-means algorithms). 
  - Notice that these shapes appear in clusters: multiple iterations of the algorithm tend to yield similar output centers. 
- The background circles change based on the deviations in the number of iterations the algorithm took on each run.
   - If R = width/2, the shade at radius r approximately corresponds to the percentage of runs that had an iteration count such that it/maxIt < r/R.
   - The lighter the image generally seems, the more deviation in the number of iterations.
   - The larger the radius of the innermost black circle, the less deviation between the most and least # of iterations.
- The number of black lines directly correlate to the standard deviation of performance.
