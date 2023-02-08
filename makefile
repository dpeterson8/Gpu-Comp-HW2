lab1: main.o pgmUtility.o pgmProcess.o
	nvcc -arch=sm_52 -o lab1 main.o pgmUtility.o pgmProcess.o  -I.

main.o: main.cu
	nvcc -arch=sm_52 -c main.cu

pgmUtility.o: pgmUtility.cu
	nvcc -arch=sm_52 -c pgmUtility.cu

pgmProcess.o: pgmProcess.cu
	nvcc -arch=sm_52 -c pgmProcess.cu

clean:
	rm -r *.o lab1