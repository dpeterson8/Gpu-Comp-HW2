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

  if (pixels == NULL) { return 0; }
  if (header == NULL) { return 0; }

  dim3 block, grid;

  block.x = 32;
  block.y = 32;

  grid.x = ceil( (float)numCols / (float)block.x );
  grid.y = ceil( (float)numRows / (float)block.y );

  dPgmDrawEdge<<<grid, block>>>(pixels, numRows, numCols, edgeWidth, header);

  return 1;

}

int pgmDrawCircle( int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius, char **header ) {

  if (pixels == NULL) { return 0; }
  if (header == NULL) { return 0; }

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

int pgmDrawLine( int *pixels, int numRows, int numCols, char **header, int p1row, int p1col, int p2row, int p2col ) {

  if (pixels == NULL) { return 0; }
  if (header == NULL) { return 0; }
  
  dim3 block, grid;

  block.x = 32;
  block.y = 32;

  int minX, maxX, minY, maxY;
  float p1r, p1c, p2r, p2c;

  p1r = p1row;
  p1c = p1col;
  p2r = p2row;
  p2c = p2col;

  minX = min(p1col, p2col);
  maxX = max(p1col, p2col);
  minY = min(p1row, p2row);
  maxY = max(p1row, p2row);

  grid.x = ceil( (float)numCols / (float)block.x );
  grid.y = ceil( (float)numRows / (float)block.y );

  float slope = ((p2r - p1r)/(p2c - p1c));
  float remainder = p1r - (slope * p1c);

  dPgmDrawLine<<<grid, block>>>(pixels, numCols, slope, remainder, p1row, p1col, minX, maxX, minY, maxY);
  
  return 1;
  
}

int pgmWrite( const char **header, const int *pixels, int numRows, int numCols, FILE *out ) {

  if (pixels == NULL) { return 0; }
  if (header == NULL) { return 0; }
  
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
