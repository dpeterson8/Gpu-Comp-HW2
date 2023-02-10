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
/*
* Given a slope-intercept form of a line, determines if the point x,y falls on that line.
*
* Note that only the first two values of linearEquation are read.
* the first value is the slope (the m of y=mx+b)
* the second value is the intercept (the b of y=mx+b)
*
*/
__device__ int isOnLine(float *linearEquation, int x, int y ){
    if(ceil((float)x*linearEquation[0] + linearEquation[1]) == y ||
       floor((float)x*linearEquation[0] + linearEquation[1]) == y  ){ //Check floor or ceiling for a thicker line hopefully
        return 1;
    } else {
        return 0;
    }
}
/* 
*
*/
__global__ void dPgmDrawLine(int* pixels, int* p1, int* p2, float* linearEquation, int numRows, int numCols){
    int ix   = blockIdx.x*blockDim.x + threadIdx.x;
    int iy   = blockIdx.y*blockDim.y + threadIdx.y;
    int idx = iy*numCols + ix;

    int left, top, right, bottom;

    //Find boundaries
    if (p1[0] < p2[0]){
        left = p1[0];
        right = p2[0];
    } else {
        left = p2[0];
        right = p1[0];
    }

    if (p1[1] < p2[1]){
        top = p1[1];
        bottom = p2[1];
    } else {
        top = p2[1];
        bottom = p1[1];
    }
    
    

    if (ix < numRows && iy < numCols){ //Check to see if the thread should be interacting with the image

        if (ix >= left && ix <= right && iy >= top && iy <= bottom) { //Check line boundaries
            if (isOnLine(linearEquation,ix,iy)){
                pixels[idx] = 0;
            }
        }
    }
}

