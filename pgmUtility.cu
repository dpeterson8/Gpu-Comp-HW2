
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#include "pgmUtility.h"
#include "pgmProcess.h"

// Implement or define each function prototypes listed in pgmUtility.h file.
// NOTE: Please follow the instructions stated in the write-up regarding the interface of the functions.
// NOTE: You might have to change the name of this file into pgmUtility.cu if needed.

int * pgmRead( char **header, int *numRows, int *numCols, FILE *in) {
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
    
    dim3 block, grid;

    block.x = 32;
    block.y = 32;

    grid.x = ceil( (float)numCols / (float)block.x );
    grid.y = ceil( (float)numRows / (float)block.y );

    dPgmDrawCircle<<<grid, block>>>(pixels, numRows, numCols, centerCol, centerRow, radius);
    
    return 1;
}

int cpuPgmDrawCircle( int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius, char **header ) {
    int i, j;

    for(i = 0; i < numRows; i++) {
        for(j = 0; j < numCols; j++) {
            int p1[2] = {i, j};
            int p2[2] = {centerRow, centerCol};
            int dis = hostDistance(p1, p2);
            if (dis <= radius)
            {
                pixels[(i * numCols) + j] = 0;
            }
            
        }
    }
    return 1;
}

int pgmDrawLine(int *pixels, int numRows, int numCols, char **header, int p1row, int p1col, int p2row, int p2col ){

    dim3 block, grid;

    block.x = 32;
    block.y = 32;

    grid.x = ceil( (float)numCols / (float)block.x );
    grid.y = ceil( (float)numRows / (float)block.y );

    int p1[2] = {p1row, p1col};
    int p2[2] = {p2row, p2col};

    float linearEquation[2];
    linearEquation[0] = (float)(p2[1] - p1[1])/(float)(p2[0] - p1[0]);
    linearEquation[1] = (float)p1[1] - (linearEquation[0] * (float)p1[0]);

    dPgmDrawLine<<<grid, block>>>(pixels, p1, p2,linearEquation, numRows, numCols);

    return 1;
}

int cpuPgmDrawLine(int *pixels, int numRows, int numCols, char **header, int p1row, int p1col, int p2row, int p2col ){


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