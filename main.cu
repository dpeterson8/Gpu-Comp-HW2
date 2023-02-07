#include <stdio.h>
#include <stdlib.h>

#include "pgmUtility.h"

int main(int argc, char *argv[]) {
    int i;
    FILE *in_temp = fopen("balloons.ascii.pgm", "r"); 
    FILE *out_temp = fopen("balloons.ascii-test.pgm", "w"); 
    char **header = ( char** ) malloc(rowsInHeader * sizeof(char *));
    for(i = 0; i < rowsInHeader; i ++) {
        header[i] = (char* ) malloc(sizeof(char) * maxSizeHeadRow);
    }

    int numRows, numCols;
    int * temp = pgmRead(header, &numRows, &numCols, in_temp);

    // for(int x = 0; x < 30; x++) {
    //     printf("%d ", temp[x]);
    // }
    int num_bytes = numCols * numRows * sizeof(int);
    int * d_temp = 0;

    cudaMalloc((void **) &d_temp, num_bytes);
    cudaMemcpy( d_temp, temp, num_bytes, cudaMemcpyHostToDevice );
    pgmDrawCircle(d_temp, numRows, numCols, 0, 0, 10, header);
    cudaDeviceSynchronize();
    cudaMemcpy( temp, d_temp, num_bytes, cudaMemcpyDeviceToHost );

    int awnser = pgmWrite((const char **) header, temp, numRows, numCols, out_temp);

    return 0;
}
