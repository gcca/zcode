package main

import (
	"regexp"
	"slices"
	"testing"
)

func MergeSortedLists(l1, l2 []int) []int {
	rs := make([]int, 0, len(l1)+len(l2))
	i, j := 0, 0

	for i < len(l1) && j < len(l2) {
		if l1[i] <= l2[j] {
			rs = append(rs, l1[i])
			i++
		} else {
			rs = append(rs, l2[j])
			j++
		}
	}

	rs = append(rs, l1[i:]...)
	rs = append(rs, l2[j:]...)

	return rs
}

func main() {
	testing.Main(regexp.MatchString, []testing.InternalTest{
		{Name: "TestMergeSortedLists", F: TestMergeSortedLists},
	}, nil, nil)
}

func TestMergeSortedLists(t *testing.T) {
	for _, tc := range []struct {
		name string
		l1   []int
		l2   []int
		want []int
	}{
		{"both inputs empty", []int{}, []int{}, []int{}},
		{"first input empty", []int{}, []int{1, 2, 3}, []int{1, 2, 3}},
		{"second input empty", []int{1, 2, 3}, []int{}, []int{1, 2, 3}},
		{"single elements ascending", []int{1}, []int{2}, []int{1, 2}},
		{"single elements descending", []int{2}, []int{1}, []int{1, 2}},
		{"equal single elements", []int{1}, []int{1}, []int{1, 1}},
		{"interleaved values", []int{1, 3, 5}, []int{2, 4, 6}, []int{1, 2, 3, 4, 5, 6}},
		{"disjoint ranges first input smaller", []int{1, 2, 3}, []int{4, 5, 6}, []int{1, 2, 3, 4, 5, 6}},
		{"disjoint ranges second input smaller", []int{4, 5, 6}, []int{1, 2, 3}, []int{1, 2, 3, 4, 5, 6}},
		{"remaining values from first input", []int{1, 3, 5, 7, 9}, []int{2, 4}, []int{1, 2, 3, 4, 5, 7, 9}},
		{"remaining values from second input", []int{2, 4}, []int{1, 3, 5, 7, 9}, []int{1, 2, 3, 4, 5, 7, 9}},
		{"duplicates within and across inputs", []int{1, 1, 2, 4}, []int{1, 2, 2, 4}, []int{1, 1, 1, 2, 2, 2, 4, 4}},
		{"negative values and zero", []int{-5, -1, 0}, []int{-4, -2, 0, 3}, []int{-5, -4, -2, -1, 0, 0, 3}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if got := MergeSortedLists(tc.l1, tc.l2); !slices.Equal(got, tc.want) {
				t.Errorf("MergeSortedLists(%v, %v) = %v; want %v", tc.l1, tc.l2, got, tc.want)
			}
		})
	}
}
