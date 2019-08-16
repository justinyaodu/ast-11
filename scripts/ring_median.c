#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define RING_NUM 60
#define RING_RADIUS 10

// valid options are HEAP and SHELL, default is insertion
#define SORT_TYPE SHELL

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

int main(void)
{
	// output results
	scanf("%d %d", &i_len, &j_len);

	// allocate memory
	data = (float*) malloc(i_len * j_len * sizeof(float));

	// read in data
	fprintf(stderr, "reading in data...\n");
	for (int i = 0; i < i_len; i++)
	{
		for (int j = 0; j < j_len; j++)
		{
			scanf("%f", &data[i * i_len + j]);
		}
	}

	// record start time
	clock_t start = clock();

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

	clock_t end = clock();

	double total_sec = ((double) (end - start)) / CLOCKS_PER_SEC;
	int nsec_per_pixel = (int)(total_sec / (i_len * j_len) * 10e9);

	fprintf(stderr, "finished in %.2f seconds, %d nsec/pixel\n", total_sec, nsec_per_pixel);

	return 0;
}
