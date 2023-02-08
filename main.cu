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

    char * drawType = argv[1];

    int i;
    for(i = 0; i < rowsInHeader; i ++) {
        header[i] = (char* ) malloc(sizeof(char) * maxSizeHeadRow);
    }

    if(drawType[1] == 'c') {
        
        circleCenterRow = atoi(argv[2]);
        circleCenterCol = atoi(argv[3]);
        circleRadius = atoi(argv[4]);
        strcpy(originalFileName, argv[5]);
        strcpy(newFileName, argv[6]);

        inFile = fopen(originalFileName, "r");
        outFile = fopen("balloons.ascii-test.pgm", "w"); 

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

    } else if(drawType[1] == 'e') {

    } else if(drawType[1] == 'l') {
        
    }

    return 0;
}
