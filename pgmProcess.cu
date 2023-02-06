#include <math.h>

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
    float y2 = p1[0];
    float distance = sqrt(((x2-x1) * (x2-x1))+((y2-y1) * (y2-y1)));

    return distance;

}