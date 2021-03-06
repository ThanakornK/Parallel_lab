#include<stdio.h>


__global__void parallel_vector_add(int* d_a, int* d_b, int* d_c, int* d_n)
{

	int i = (blockIdx.x*blockDim.x)+threadIdx.x;
	//printf("I am thread #%d.",i);
	if(i < *d_n){
		printf("I am thread #%d, and about to compute c[%d].\n", i, i);
		d_c[i] = d_a[i]+d_b[i];
	}
	else {
		printf("I am thread #%d, and doing nothing.\n", i);
	}
}

int main() {

	// declare input and output on host
	int n;
	scanf("%d", &n);
	int h_a[n] ;
	int h_b[n] ;
	int h_c[n] ;
	
	for(i=0; i<n; i++)
	{
		h_a[i] = i;
		h_b[i] = n-i;
	}
	
	// Part 1: Copy data from host to device
	int *d_a, *d_b, *d_c, *d_n;
	cudaMalloc((void **) &d_a, n*sizeof(int));
	cudaMalloc((void **) &d_b, n*sizeof(int));
	cudaMalloc((void **) &d_c, n*sizeof(int));
	cudaMalloc((void **) &d_a, sizeof(int));

	// timing CUDA event
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	
	cudaMemcpy(d_a, &h_a, n*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, &h_b, n*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_n, &n, sizeof(int), cudaMemcpyHostToDevice);
	
	// Part 2: Kernel launch
	int nBlock;
	if (n % 512) {
		nBlock = (n/512) + 1;
	}
	else {
		nBlock = n/512;
	}

	cudaEventRecord(start);

	parallel_vector_add<<<nBlock, 512>>>(d_a, d_b, d_c, d_n);
	cudaDeviceSynchronize(stop);

	cudaEventRecord(stop);
	
	// Part 3: Copy data from device back to host, and free all data allocate on device
	cudaMemcpy(&h_c, d_c, n*sizeof(int), cudaMemcpyDeviceToHost);

	cudaEventSynchronize(stop);
	float millisec = 0;
	cudaEventElapsedTime(&millisec, start, stop);

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	
	for(int i=0; i<n; i++)
		printf("%d ", h_c[i]);

	printf*("\ntime used = %f\n", millisec);
}