# seq0. Summing A Sequence

Given a sequence of integers, choose elements to maximize their sum. Two
elements in consecutive positions cannot both be chosen. Choosing no elements
gives a sum of zero. [DMOJ problem statement](https://dmoj.ca/problem/seq0)

## Input and output

The first line gives the number of elements, `N`, and the second line gives the
`N` space-separated integers. The output is the maximum sum.

- `1 <= N <= 1_000_000`
- `-1_000_000_000 <= a[i] <= 1_000_000_000`

## Sample input

```text
6
1 3 -2 5 -7 10
```

## Sample output

```text
18
```

## Prolog solutions

`max_non_adjacent_sum_recursive/2` tries taking or skipping the first element.
It recomputes results for overlapping suffixes, so its runtime is exponential.

`max_non_adjacent_sum/2` scans the list once. It keeps the best sums for the
previous two prefix lengths, using O(N) time and O(1) auxiliary space beyond
the input list.

Run the tests with `ninja seq0-pl`.
