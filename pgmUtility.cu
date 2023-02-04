
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "pgmUtility.h"

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

int pgmDrawCircle( int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius, char **header ) {
    return 1;
}

int main(int argc, char *argv[]) {

    int i, j;
    FILE *in_temp = fopen("balloons.ascii.pgm", "r"); 
    char **header = ( char** ) malloc(rowsInHeader * sizeof(char *));
    for(i = 0; i < rowsInHeader; i ++) {
        header[i] = (char* ) malloc(sizeof(char) * maxSizeHeadRow);
    }

    int numRows, numCols;
    int * temp = pgmRead(header, &numRows, &numCols, in_temp);
    for(i = 0; i < numRows; i++) {
        for (j = 0; j < numCols; j++) {
            printf("%d ", *(temp + (i * j)));
        }
        printf("\n");
    }

    // for(int x = 0; x < 30; x++) {
    //     printf("%d ", temp[x]);
    // }


    return 0;
}