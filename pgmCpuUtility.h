int cpuPgmDrawCircle( int *pixels, int numRows, int numCols, int centerRow, int centerCol, int radius, char **header );

int cpuPgmDrawEdge( int *pixels, int numRows, int numCols, int edgeWidth, char **header );

int cpuPgmDrawLine( int *pixels, int numRows, int numCols, char **header, int p1row, int p1col, int p2row, int p2col );

float hostDistance( int p1[], int p2[] );

void displayError();

double currentTime();