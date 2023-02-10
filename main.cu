#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "pgmUtility.h"


int main(int argc, char *argv[]) {
  FILE *inFile;
  FILE *outFile;
  char **header = ( char** ) malloc(rowsInHeader * sizeof(char *));

  int circleCenterRow, circleCenterCol, circleRadius;
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
      pgmDrawCircle(dPixels, numRows, numCols, circleCenterRow, circleCenterCol, circleRadius, header);
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
        
        

    } else if(drawType[1] == 'l') {
        printf("Entering line draw mode\n");
        //TODO: Error checking 
        //Parse Parameters
        int p1x, p1y, p2x, p2y;
        p1x = atoi(argv[2]); 
        p1y = atoi(argv[3]);
        p2x = atoi(argv[4]);
        p2y = atoi(argv[5]);

        strcpy(originalFileName, argv[6]);
        strcpy(newFileName, argv[7]);
        //Open file streams
        inFile = fopen(originalFileName, "r");
        outFile = fopen(newFileName, "w");
        //Time and launch CPU code
        //cpuPgmDrawLine(hPixels, numRows, numCols, header, p1x, p1y, p2x, p2y);

        //Time and launch Kernel

        //cuda Memcpy
        hPixels = pgmRead(header, &numRows, &numCols, inFile);
        num_bytes = numCols * numRows * sizeof(int);

        cudaMalloc((void **) &dPixels, num_bytes);
        cudaMemcpy( dPixels, hPixels, num_bytes, cudaMemcpyHostToDevice );
        pgmDrawLine(hPixels, numRows, numCols, header, p1x, p1y, p2x, p2y);
        cudaDeviceSynchronize();
        cudaMemcpy( hPixels, dPixels, num_bytes, cudaMemcpyDeviceToHost );
        cudaFree(dPixels);
        //Print Time

        //Write to new pgm with one of these results
        pgmWrite((const char **) header, hPixels, numRows, numCols, outFile);
        printf("Should've made pgm image\n");
        //Free memory
        for(i = 0; i < rowsInHeader; i++) {
            free(header[i]);
        }
        free(header);
        free(hPixels);
    }

  return 0;
}
