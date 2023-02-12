#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include <sys/time.h>
#include "pgmCpuUtility.h"

int cpuPgmDrawCircle( int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius, char **header ) {
  
  if (header == NULL) { return 0; }
  if (pixels == NULL) { return 0; }
  
  int i, j;

  for(i = 0; i < numRows; i++) {
    for(j = 0; j < numCols; j++) {

      int p1[2] = {i, j};
      int p2[2] = {centerRow, centerCol};
      int dis = hostDistance(p1, p2);

      if (dis <= radius) {
        pixels[(i * numCols) + j] = 0;
      }
        
    }
  }

  return 1;

}

int cpuPgmDrawEdge( int *pixels, int numRows, int numCols, int edgeWidth, char **header ) {
  
  if (header == NULL) { return 0; }
  if (pixels == NULL) { return 0; }
  
  int i, j;

  for(i = 0; i < numRows; i++) {
    for(j = 0; j < numCols; j++) {
      if(j < numCols && i < numRows) {
        if((j <= edgeWidth || i <= edgeWidth) || (j >= numCols - edgeWidth || i >= numRows - edgeWidth)) {
          pixels[(i * numCols) + j] = 0;
        }
      }
    }
  }

  return 1;

}

int cpuPgmDrawLine( int *pixels, int numRows, int numCols, char **header, int p1row, int p1col, int p2row, int p2col ) {
  int i, j;

  float minx, maxx, miny, maxy;
  float slope, intercept;
  float p1r, p1c, p2r, p2c;
  p1r = p1row;
  p1c = p1col;
  p2r = p2row;
  p2c = p2col;

  minx = min(p1col, p2col);
  maxx = max(p1col, p2col);
  miny = min(p1row, p2row);
  maxy = max(p1row, p2row);
  
  if((p2c-p1c) != 0) {
    slope = ((p2r-p1r)/(p2c-p1c));
  } else {
    slope = 0;
  }
  intercept = p2r - (slope * p2c);

  for(i = 0; i < numRows; i++) {
    for(j = 0; j < numCols; j++) {

      if (i == ceil(((float)j * slope) + intercept)) {
        if(j >= minx && j <= maxx && i >= miny && i <= maxy) {
          pixels[(i * numCols) + j] = 0;
        }
      }

    }
  }

  return 1;

}

float hostDistance( int p1[], int p2[] )
{
  float x1 = p1[1];
  float x2 = p2[1];
  float y1 = p1[0];
  float y2 = p2[0];
  float distance = sqrt(((x2-x1) * (x2-x1))+((y2-y1) * (y2-y1)));
  
  return distance;

}

void displayError() {
  printf("Usage:\n");
  printf("-e edgeWidth oldImageFile newImageFile\n");
  printf("-c circleCenterRow circleCenterCol radius oldImageFile newImageFile\n");
  printf("-l p1row p1col p2row p2col oldImageFile newImageFile");
  printf("You have to run the command with the synopsis: \n\n");

  printf("./programName -e edgeWidth originalImage newImage\n");
  printf("to paint an edge of width edgeWidth in the image of originalIamge\n\n");

  printf("./programName -c circleCenterRow circleCenterCol radius oldImageFile newImageFile\n");
  printf("to paint a big round dot on the image with center at (circleCenterRow,\n");
  printf("circleCenterCol) and radius of radius\n\n");

  printf("./programName -l p1row p1col p2row p2col oldImageFile newImageFile\n");
  printf("to draw a line at a start point with row number = p1row and column\n");
  printf("number = p1col, the line segment ends at a point with row number =\n");
  printf("p2row and column number = p2co\n\n");
}

double currentTime() {
  struct timeval now;
  gettimeofday(&now, NULL);

  return now.tv_sec + now.tv_usec/1000000.0;
}
