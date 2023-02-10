#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "pgmUtility.h"

int main(int argc, char *argv[]) {
  FILE *inFile;
  FILE *outFile;
  char **header = ( char** ) malloc(rowsInHeader * sizeof(char *));

  int circleCenterRow, circleCenterCol, circleRadius;
  int p1row, p1col, p2row, p2col;
  char originalFileName[100], newFileName[100];
  int numRows, numCols;
  int * hPixels, * dPixels;
  int num_bytes;
  char * drawType;

  if (argv[1] != NULL) {
    drawType = argv[1];
  } else { displayError(); }

  int i;
  for(i = 0; i < rowsInHeader; i ++) {
    header[i] = (char* ) malloc(sizeof(char) * maxSizeHeadRow);
  }

  if(drawType[1] == 'c') {
    if(argc == 7) {
      circleCenterRow = atoi(argv[2]);
      circleCenterCol = atoi(argv[3]);
      circleRadius = atoi(argv[4]);
      strcpy(originalFileName, argv[5]);
      strcpy(newFileName, argv[6]);

      inFile = fopen(originalFileName, "r");
      outFile = fopen(newFileName, "w"); 

      hPixels = pgmRead(header, &numRows, &numCols, inFile);
      num_bytes = numCols * numRows * sizeof(int);

      cpuPgmDrawCircle(hPixels, numRows, numCols, circleCenterRow, circleCenterCol, circleRadius, header);

      cudaMalloc((void **) &dPixels, num_bytes);
      cudaMemcpy( dPixels, hPixels, num_bytes, cudaMemcpyHostToDevice );
      pgmDrawCircle(dPixels, numRows, numCols, circleCenterCol, circleCenterRow, circleRadius, header);
      cudaDeviceSynchronize();
      cudaMemcpy( hPixels, dPixels, num_bytes, cudaMemcpyDeviceToHost );
      cudaFree(dPixels);

      int ret = pgmWrite((const char **) header, hPixels, numRows, numCols, outFile);
      for(i = 0; i < rowsInHeader; i++) {
          free(header[i]);
      }
      free(header);
      free(hPixels);
    } else {
      displayError();
    }      

  } else if(drawType[1] == 'e') {
      int edgeWidth = atoi(argv[2]);
      strcpy(originalFileName, argv[3]);
      strcpy(newFileName, argv[4]);

      inFile = fopen(originalFileName, "r");
      outFile = fopen(newFileName, "w"); 

      hPixels = pgmRead(header, &numRows, &numCols, inFile);
      num_bytes = numCols * numRows * sizeof(int);

      cudaMalloc((void **) &dPixels, num_bytes);
      cudaMemcpy( dPixels, hPixels, num_bytes, cudaMemcpyHostToDevice );
      pgmDrawEdge(dPixels, numRows, numCols, edgeWidth, header);
      cudaDeviceSynchronize();
      cudaMemcpy( hPixels, dPixels, num_bytes, cudaMemcpyDeviceToHost );
      cudaFree(dPixels);

      int ret = pgmWrite((const char **) header, hPixels, numRows, numCols, outFile);
      for(i = 0; i < rowsInHeader; i++) {
          free(header[i]);
      }
      free(header);
      free(hPixels);
  } else if(drawType[1] == 'l') {
      p1row = atoi(argv[2]);
      p1col = atoi(argv[3]);
      p2row = atoi(argv[4]);
      p2col = atoi(argv[5]);
      strcpy(originalFileName, argv[6]);
      strcpy(newFileName, argv[7]);

      inFile = fopen(originalFileName, "r");
      outFile = fopen(newFileName, "w"); 

      hPixels = pgmRead(header, &numRows, &numCols, inFile);
      num_bytes = numCols * numRows * sizeof(int);

      cudaMalloc((void **) &dPixels, num_bytes);
      cudaMemcpy( dPixels, hPixels, num_bytes, cudaMemcpyHostToDevice );
      pgmDrawLine(dPixels, numRows, numCols, header, p1row, p1col, p2row, p2col);
      cudaDeviceSynchronize();
      cudaMemcpy( hPixels, dPixels, num_bytes, cudaMemcpyDeviceToHost );
      cudaFree(dPixels);

      int ret = pgmWrite((const char **) header, hPixels, numRows, numCols, outFile);
      for(i = 0; i < rowsInHeader; i++) {
          free(header[i]);
      }
      free(header);
      free(hPixels);
  } else { displayError(); }

  return 0;
}
