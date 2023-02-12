#include <math.h>
#include <stdlib.h>
#include <stdio.h>


/**
 *  Function Name:
 *      distance()
 *      distance() returns the Euclidean distance between two pixels. This function is executed on CUDA device
 *
 *  @param[in]  p1  coordinates of pixel one, p1[0] is for row number, p1[1] is for column number
 *  @param[in]  p2  coordinates of pixel two, p2[0] is for row number, p2[1] is for column number
 *  @return         return distance between p1 and p2
 */
__device__ float distance( int p1[], int p2[] )
{
  float x1 = p1[1];
  float x2 = p2[1];
  float y1 = p1[0];
  float y2 = p2[0];
  float distance = sqrt(((x2-x1) * (x2-x1))+((y2-y1) * (y2-y1)));

  return distance;

}

__device__ float findSlope( int p1[], int p2[]) {
  float x1 = p1[1];
  float x2 = p2[1];
  float y1 = p1[0];
  float y2 = p2[0];
  float slope = ((y2-y1)/(x2-x1));

  return slope;
}

__global__ void dPgmDrawCircle(int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius) {
  int ix   = blockIdx.x*blockDim.x + threadIdx.x;
  int iy   = blockIdx.y*blockDim.y + threadIdx.y;
  int idx = iy*numCols + ix;

  int p1[2] = {iy, ix % numCols};
  int p2[2] = {centerRow, centerCol};
  float dis = distance(p1, p2);
  
  if(dis <= radius) {
    pixels[idx] = 0;
  }

}

__global__ void dPgmDrawEdge(int *pixels, int numRows, int numCols, int edgeWidth, char ** header) {
  int ix   = blockIdx.x*blockDim.x + threadIdx.x;
  int iy   = blockIdx.y*blockDim.y + threadIdx.y;
  int idx = iy*numCols + ix;

  if(ix < numCols && iy < numRows) {
    if((ix <= edgeWidth || iy <= edgeWidth) || (ix >= numCols - edgeWidth || iy >= numRows - edgeWidth)) {
      pixels[idx] = 0;
    }
  }
}

__global__ void dPgmDrawLine(int *pixels, int numCols, float slope, float rem, int p1row, int p1col, int minX, int maxX, int minY, int maxY) {
  int ix   = blockIdx.x*blockDim.x + threadIdx.x;
  int iy   = blockIdx.y*blockDim.y + threadIdx.y;
  int idx = iy*numCols + ix;

  int x = (ix % numCols);
  if(iy == round(((float)x * slope + rem))) {
    if(x >= minX && x <= maxX && iy >= minY && iy <= maxY) {
      pixels[idx] = 0;
    }
  }

}
