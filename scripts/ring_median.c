#include <stdio.h>
#include <stdlib.h>

#define RING_NUM 60

int i_len, j_len;

// int ring_i[RING_NUM] = {0, 4, 7, 8, 7, 4, 0, -4, -7, -8, -7, -4};
// int ring_j[RING_NUM] = {8, 7, 4, 0, -4, -7, -8, -7, -4, 0, 4, 7};
int ring_i[RING_NUM] = {1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 9, 10, 10, 10, -1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -9, -10, -10, -10, 1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 9, 10, 10, 10, -1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -9, -10, -10, -10, 10, 0, -10, 0};
int ring_j[RING_NUM] = {10, 10, 10, 9, 9, 8, 8, 7, 6, 5, 4, 3, 2, 1, -10, -10, -10, -9, -9, -8, -8, -7, -6, -5, -4, -3, -2, -1, -10, -10, -10, -9, -9, -8, -8, -7, -6, -5, -4, -3, -2, -1, 10, 10, 10, 9, 9, 8, 8, 7, 6, 5, 4, 3, 2, 1, 0, 10, 0, -10};
// int ring_i[RING_NUM] = {2, 0, -2, 0};
// int ring_j[RING_NUM] = {0, 2, 0, -2};
float ring_values[RING_NUM];

float *data;

void sort_ring_values(int count)
{
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

int main(void)
{
	// output results
	scanf("%d %d", &i_len, &j_len);

	// allocate memory
	data = (float*) malloc(i_len * j_len * sizeof(float));

	// read in data
	for (int i = 0; i < i_len; i++)
	{
		for (int j = 0; j < j_len; j++)
		{
			scanf("%f", &data[i * i_len + j]);
		}
	}

	for (int i = 0; i < i_len; i++)
	{
		fprintf(stderr, "processing row %d of %d\n", i + 1, i_len);
		for (int j = 0; j < j_len; j++)
		{
			printf("%f ", data[i * i_len + j] - ring_median(i, j));
		}
		printf("\n");
	}

	return 0;
}
