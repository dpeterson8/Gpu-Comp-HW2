myPaint: main.o pgmUtility.o pgmProcess.o pgmCpuUtility.o
	nvcc -arch=sm_52 -o myPaint main.o pgmUtility.o pgmProcess.o pgmCpuUtility.o  -I.

main.o: main.cu
	nvcc -arch=sm_52 -c main.cu

pgmUtility.o: pgmUtility.cu
	nvcc -arch=sm_52 -c pgmUtility.cu

pgmProcess.o: pgmProcess.cu
	nvcc -arch=sm_52 -c pgmProcess.cu

pgmCpuUtility.o: pgmCpuUtility.cu
	nvcc -arch=sm_52 -c pgmCpuUtility.cu	

clean:
	rm -r *.o myPaint