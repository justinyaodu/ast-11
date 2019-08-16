#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define RING_NUM 60
#define RING_RADIUS 10

// valid options are HEAP and SHELL, default is insertion
#define SORT_TYPE SHELL

// whether to scan input in chunks of 100
// tentatively shown to have a ~25% performance improvement
#define BATCH_SCANF

int i_len, j_len;

int ring_i[RING_NUM] = {1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 9, 10, 10, 10, -1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -9, -10, -10, -10, 1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 9, 10, 10, 10, -1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -9, -10, -10, -10, 10, 0, -10, 0};
int ring_j[RING_NUM] = {10, 10, 10, 9, 9, 8, 8, 7, 6, 5, 4, 3, 2, 1, -10, -10, -10, -9, -9, -8, -8, -7, -6, -5, -4, -3, -2, -1, -10, -10, -10, -9, -9, -8, -8, -7, -6, -5, -4, -3, -2, -1, 10, 10, 10, 9, 9, 8, 8, 7, 6, 5, 4, 3, 2, 1, 0, 10, 0, -10};

float ring_values[RING_NUM];

float *data;

void sort_ring_values(int count)
{
#if SORT_TYPE == HEAP
	// construct max heap
	for (int i = 1; i < count; i++)
	{
		float value = ring_values[i];
		int dest = i;

		while (dest > 0)
		{
			int parent = (dest - 1) / 2;

			if (ring_values[parent] < value)
			{
				ring_values[dest] = ring_values[parent];
				dest = parent;
			}
			else
			{
				break;
			}
		}

		ring_values[dest] = value;
	}

	// minimum index needed to be reached to calculate median
	int min_reach = (count - 1) / 2;
	
	// start building sorted array at end
	for (int i = count - 1; i >= min_reach; i--)
	{
		// store value to reheap
		float value = ring_values[i];
		
		// move largest element to end
		ring_values[i] = ring_values[0];

		int dest = 0;

		while (1)
		{
			int left = 2 * dest + 1;

			// break if left index goes past the heap,
			// meaning this node has no children
			if (left >= i) break;
		
			// find maximum of two children	

			float children_max = ring_values[left];
			int max_index = left;

			int right = 2 * dest + 2;
			if (right < i && ring_values[right] > children_max)
			{
				max_index = right;
				children_max = ring_values[right];
			}

			// if current value is greater than maximum
			// of children, stop here
			if (children_max < value) break;

			// otherwise, promote largest child to current
			// position, and repeat from child's position
			ring_values[dest] = children_max;
			dest = max_index;
		}

		ring_values[dest] = value;
	}
#elif SORT_TYPE == SHELL
	static int[] gaps = {10, 4, 1};

	for (int gi = 0; gi < sizeof(gaps) / sizeof(gaps[0]); gi++)
	{
		int gap = gaps[gi];
		
		for (int start = 0; start < gap; start++)
		{
			for (int i = gap; i < count; i++)
			{
				float value = ring_values[i];
				int dest = i;

				while (dest > start && ring_values[dest - gap] > value)
				{
					ring_values[dest] = ring_values[dest - gap];
					dest -= gap;
				}
				
				ring_values[dest] = value;
			}
		}
	}
#else
	for (int i = 1; i < count; i++)
	{
		float value = ring_values[i];
		int j = i;

		while (j > 0 && ring_values[j - 1] > value)
		{
			ring_values[j] = ring_values[j - 1];
			j--;
		}

		ring_values[j] = value;
	}
#endif
}

float ring_median(int i_center, int j_center)
{
	int count = 0;

	for (int r = 0; r < RING_NUM; r++)
	{
		int i = i_center + ring_i[r];
		int j = j_center + ring_j[r];
		if (i < 0 || i >= i_len || j < 0 || j >= j_len) continue;
		ring_values[count++] = data[i * i_len + j];
	}

	sort_ring_values(count);

	if (count % 2 == 0)
		return (ring_values[count/2 - 1] + ring_values[count/2]) / 2;
	else
		return ring_values[count/2];
}

// same as ring_median, but without bounds checking
float ring_median_unsafe(int i_center, int j_center)
{
	for (int r = 0; r < RING_NUM; r++)
	{
		int i = i_center + ring_i[r];
		int j = j_center + ring_j[r];
		ring_values[r] = data[i * i_len + j];
	}

	sort_ring_values(RING_NUM);

	return (ring_values[RING_NUM/2 - 1] + ring_values[RING_NUM/2]) / 2;
}

#define SCANF_100(i, i_len, j) scanf("%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f", \
&data[i * i_len + j +  0],\
&data[i * i_len + j +  1],\
&data[i * i_len + j +  2],\
&data[i * i_len + j +  3],\
&data[i * i_len + j +  4],\
&data[i * i_len + j +  5],\
&data[i * i_len + j +  6],\
&data[i * i_len + j +  7],\
&data[i * i_len + j +  8],\
&data[i * i_len + j +  9],\
&data[i * i_len + j + 10],\
&data[i * i_len + j + 11],\
&data[i * i_len + j + 12],\
&data[i * i_len + j + 13],\
&data[i * i_len + j + 14],\
&data[i * i_len + j + 15],\
&data[i * i_len + j + 16],\
&data[i * i_len + j + 17],\
&data[i * i_len + j + 18],\
&data[i * i_len + j + 19],\
&data[i * i_len + j + 20],\
&data[i * i_len + j + 21],\
&data[i * i_len + j + 22],\
&data[i * i_len + j + 23],\
&data[i * i_len + j + 24],\
&data[i * i_len + j + 25],\
&data[i * i_len + j + 26],\
&data[i * i_len + j + 27],\
&data[i * i_len + j + 28],\
&data[i * i_len + j + 29],\
&data[i * i_len + j + 30],\
&data[i * i_len + j + 31],\
&data[i * i_len + j + 32],\
&data[i * i_len + j + 33],\
&data[i * i_len + j + 34],\
&data[i * i_len + j + 35],\
&data[i * i_len + j + 36],\
&data[i * i_len + j + 37],\
&data[i * i_len + j + 38],\
&data[i * i_len + j + 39],\
&data[i * i_len + j + 40],\
&data[i * i_len + j + 41],\
&data[i * i_len + j + 42],\
&data[i * i_len + j + 43],\
&data[i * i_len + j + 44],\
&data[i * i_len + j + 45],\
&data[i * i_len + j + 46],\
&data[i * i_len + j + 47],\
&data[i * i_len + j + 48],\
&data[i * i_len + j + 49],\
&data[i * i_len + j + 50],\
&data[i * i_len + j + 51],\
&data[i * i_len + j + 52],\
&data[i * i_len + j + 53],\
&data[i * i_len + j + 54],\
&data[i * i_len + j + 55],\
&data[i * i_len + j + 56],\
&data[i * i_len + j + 57],\
&data[i * i_len + j + 58],\
&data[i * i_len + j + 59],\
&data[i * i_len + j + 60],\
&data[i * i_len + j + 61],\
&data[i * i_len + j + 62],\
&data[i * i_len + j + 63],\
&data[i * i_len + j + 64],\
&data[i * i_len + j + 65],\
&data[i * i_len + j + 66],\
&data[i * i_len + j + 67],\
&data[i * i_len + j + 68],\
&data[i * i_len + j + 69],\
&data[i * i_len + j + 70],\
&data[i * i_len + j + 71],\
&data[i * i_len + j + 72],\
&data[i * i_len + j + 73],\
&data[i * i_len + j + 74],\
&data[i * i_len + j + 75],\
&data[i * i_len + j + 76],\
&data[i * i_len + j + 77],\
&data[i * i_len + j + 78],\
&data[i * i_len + j + 79],\
&data[i * i_len + j + 80],\
&data[i * i_len + j + 81],\
&data[i * i_len + j + 82],\
&data[i * i_len + j + 83],\
&data[i * i_len + j + 84],\
&data[i * i_len + j + 85],\
&data[i * i_len + j + 86],\
&data[i * i_len + j + 87],\
&data[i * i_len + j + 88],\
&data[i * i_len + j + 89],\
&data[i * i_len + j + 90],\
&data[i * i_len + j + 91],\
&data[i * i_len + j + 92],\
&data[i * i_len + j + 93],\
&data[i * i_len + j + 94],\
&data[i * i_len + j + 95],\
&data[i * i_len + j + 96],\
&data[i * i_len + j + 97],\
&data[i * i_len + j + 98],\
&data[i * i_len + j + 99])

int main(void)
{
	// output results
	scanf("%d %d", &i_len, &j_len);

	// allocate memory
	data = (float*) malloc(i_len * j_len * sizeof(float));

	clock_t input_start = clock();

	// read in data
	for (int i = 0; i < i_len; i++)
	{
		if (i % 100 == 0)
		{
			fprintf(stderr, "reading row %d of %d\n", i + 1, i_len);
		}

		int j = 0;
#ifdef BATCH_SCANF
		while (j_len - j >= 100)
		{
			SCANF_100(i, i_len, j);
			j += 100;
		}
#endif
		while (j < j_len)
		{
			scanf("%f", &data[i * i_len + j]);
			j++;
		}
	}

	clock_t input_end = clock();

	double input_total_sec = ((double) (input_end - input_start)) / CLOCKS_PER_SEC;
	int input_nsec_per_pixel = (int)(input_total_sec / (i_len * j_len) * 10e9);

	fprintf(stderr, "input parsed in %.2f CPU seconds, %d nsec/pixel\n", input_total_sec, input_nsec_per_pixel);
	// record start time
	clock_t compute_start = clock();

	for (int i = 0; i < i_len; i++)
	{
		int i_safe = (i >= RING_RADIUS) && (i < i_len - RING_RADIUS);

		if (i % 100 == 0)
		{
			fprintf(stderr, "processing row %d of %d\n", i + 1, i_len);
		}

		for (int j = 0; j < j_len; j++)
		{
			float value;

			// use the faster ring_median function without bounds checking
			// if the ring is completely contained within the image
			if (i_safe)
			{
				int j_safe = (j >= RING_RADIUS) && (j < j_len - RING_RADIUS);
				if (j_safe)
				{
					value = ring_median_unsafe(i, j);
				}
				else
				{
					value = ring_median(i, j);
				}
			}
			else
			{
				value = ring_median(i, j);
			}

			printf("%f ", data[i * i_len + j] - value);
		}
		printf("\n");
	}

	clock_t compute_end = clock();

	double total_sec = ((double) (compute_end - compute_start)) / CLOCKS_PER_SEC;
	int nsec_per_pixel = (int)(total_sec / (i_len * j_len) * 10e9);

	fprintf(stderr, "finished in %.2f CPU seconds, %d nsec/pixel\n", total_sec, nsec_per_pixel);

	return 0;
}
