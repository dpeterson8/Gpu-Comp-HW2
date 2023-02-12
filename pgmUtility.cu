#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "pgmUtility.h"
#include "pgmProcess.h"

// Implement or define each function prototypes listed in pgmUtility.h file.
// NOTE: Please follow the instructions stated in the write-up regarding the interface of the functions.
// NOTE: You might have to change the name of this file into pgmUtility.cu if needed.

int * pgmRead( char **header, int *numRows, int *numCols, FILE *in  ) {

  int i, j;

  for( i = 0; i < rowsInHeader; i++) {
    if(header[i] == NULL) {
      return NULL;
    }
    if(fgets(header[i], maxSizeHeadRow, in) == NULL) {
      return NULL;
    }
  }
  
  sscanf( header[rowsInHeader - 2], "%d %d", numCols, numRows);

  int *pixels = (int *) malloc((*numRows * *numCols) * sizeof(int ));

  for(i = 0; i < *numRows; i++) {
      for(j = 0; j < *numCols; j++) {
        if( fscanf(in, "%d ", pixels + ((i * *numCols) + j) ) < 0) {
        return NULL;
      }
    }
  }

  return pixels;
}

int pgmDrawEdge( int *pixels, int numRows, int numCols, int edgeWidth, char **header ) {

  dim3 block, grid;

  block.x = 32;
  block.y = 32;

  grid.x = ceil( (float)numCols / (float)block.x );
  grid.y = ceil( (float)numRows / (float)block.y );

  dPgmDrawEdge<<<grid, block>>>(pixels, numRows, numCols, edgeWidth, header);
  return 1;
}

int pgmDrawCircle( int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius, char **header ) {

  if (header == NULL) {
    return 0;
  } else if (pixels == NULL) {
    return 0;
  }
    
  dim3 block, grid;

  block.x = 32;
  block.y = 32;

  grid.x = ceil( (float)numCols / (float)block.x );
  grid.y = ceil( (float)numRows / (float)block.y );

  dPgmDrawCircle<<<grid, block>>>(pixels, numRows, numCols, centerCol, centerRow, radius);
  
  return 1;

}

int cpuPgmDrawCircle( int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius, char **header ) {
  
  if (header == NULL) {
    return 0;
  } else if (pixels == NULL) {
    return 0;
  }
  
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

int pgmDrawLine( int *pixels, int numRows, int numCols, char **header, int p1row, int p1col, int p2row, int p2col ) {
  dim3 block, grid;

  block.x = 32;
  block.y = 32;

  grid.x = ceil( (float)numCols / (float)block.x );
  grid.y = ceil( (float)numRows / (float)block.y );

  float slope = ((p2row - p1row)/(p2col - p1col));
  float remainder = p1row - (slope * p1col);

  // if(p1row == (p1col * slope) + remainder) {
  //   printf("Working");
  // }

  dPgmDrawLine<<<grid, block>>>(pixels, numRows, numCols, slope, remainder, p1row, p1col);
  
  return 1;
  
}

int cpuPgmDrawLine( int *pixels, int numRows, int numCols, char **header, int p1row, int p1col, int p2row, int p2col ) {
  int i, j;

  float slope, intercept;
  float p1r, p1c, p2r, p2c;
  p1r = p1row;
  p1c = p1col;
  p2r = p2row;
  p2c = p2col;
  
  slope = ((p2r-p1r)/(p2c-p1c));
  intercept = p2r - (slope * p2c);

  for(i = 0; i < numRows; i++) {
    for(j = 0; j < numCols; j++) {

      if (i == ceil(((float)j * slope) + intercept)) {
        pixels[(i * numCols) + j] = 0;
      }

    }
  }

  return 1;

}


int pgmWrite( const char **header, const int *pixels, int numRows, int numCols, FILE *out ) {
  
  int i, j;

  for(i = 0; i<rowsInHeader; i++) {
    fprintf(out ,"%s" , *(header + i));
  }

  for(i = 0; i < numRows; i++) {
    for(j = 0; j < numCols; j++) {
      if(j < numCols - 1) {
        fprintf(out, "%d ", *(pixels +((i * numCols) + j)));
      } else {
        fprintf(out, "%d\n", *(pixels +((i * numCols) + j)));
      }
    }
  }
  return 0;
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