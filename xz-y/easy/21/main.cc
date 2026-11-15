#include <gtest/gtest.h>

std::vector<int> MergeSortedLists(const std::vector<int> &l1,
                                  const std::vector<int> &l2) {
  std::vector<int> lr;
  lr.reserve(l1.size() + l2.size());

  auto i1 = l1.cbegin();
  auto i2 = l2.cbegin();

  auto ci = i1;

  while ((i1 != l1.cend()) and (i2 != l2.cend()))
    if (*i1 <= *i2)
      lr.push_back(*i1++);
    else
      lr.push_back(*i2++);

  lr.insert(lr.end(), i1, l1.cend());
  lr.insert(lr.end(), i2, l2.cend());

  return lr;
}

TEST(MergeSortedListsTest, HandlesBothInputsEmpty) {
  EXPECT_EQ(MergeSortedLists({}, {}), std::vector<int>{});
}

TEST(MergeSortedListsTest, HandlesFirstInputEmpty) {
  EXPECT_EQ(MergeSortedLists({}, {1, 2, 3}), (std::vector<int>{1, 2, 3}));
}

TEST(MergeSortedListsTest, HandlesSecondInputEmpty) {
  EXPECT_EQ(MergeSortedLists({1, 2, 3}, {}), (std::vector<int>{1, 2, 3}));
}

TEST(MergeSortedListsTest, MergesSingleElementsInAscendingOrder) {
  EXPECT_EQ(MergeSortedLists({1}, {2}), (std::vector<int>{1, 2}));
}

TEST(MergeSortedListsTest, MergesSingleElementsInDescendingOrder) {
  EXPECT_EQ(MergeSortedLists({2}, {1}), (std::vector<int>{1, 2}));
}

TEST(MergeSortedListsTest, PreservesEqualSingleElements) {
  EXPECT_EQ(MergeSortedLists({1}, {1}), (std::vector<int>{1, 1}));
}

TEST(MergeSortedListsTest, MergesInterleavedValues) {
  EXPECT_EQ(MergeSortedLists({1, 3, 5}, {2, 4, 6}),
            (std::vector<int>{1, 2, 3, 4, 5, 6}));
}

TEST(MergeSortedListsTest, MergesDisjointRangesWithFirstInputSmaller) {
  EXPECT_EQ(MergeSortedLists({1, 2, 3}, {4, 5, 6}),
            (std::vector<int>{1, 2, 3, 4, 5, 6}));
}

TEST(MergeSortedListsTest, MergesDisjointRangesWithSecondInputSmaller) {
  EXPECT_EQ(MergeSortedLists({4, 5, 6}, {1, 2, 3}),
            (std::vector<int>{1, 2, 3, 4, 5, 6}));
}

TEST(MergeSortedListsTest, PreservesRemainingValuesFromFirstInput) {
  EXPECT_EQ(MergeSortedLists({1, 3, 5, 7, 9}, {2, 4}),
            (std::vector<int>{1, 2, 3, 4, 5, 7, 9}));
}

TEST(MergeSortedListsTest, PreservesRemainingValuesFromSecondInput) {
  EXPECT_EQ(MergeSortedLists({2, 4}, {1, 3, 5, 7, 9}),
            (std::vector<int>{1, 2, 3, 4, 5, 7, 9}));
}

TEST(MergeSortedListsTest, PreservesDuplicatesWithinAndAcrossInputs) {
  EXPECT_EQ(MergeSortedLists({1, 1, 2, 4}, {1, 2, 2, 4}),
            (std::vector<int>{1, 1, 1, 2, 2, 2, 4, 4}));
}

TEST(MergeSortedListsTest, MergesNegativeValuesAndZero) {
  EXPECT_EQ(MergeSortedLists({-5, -1, 0}, {-4, -2, 0, 3}),
            (std::vector<int>{-5, -4, -2, -1, 0, 0, 3}));
}
