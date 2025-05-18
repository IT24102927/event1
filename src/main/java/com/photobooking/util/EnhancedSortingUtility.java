package com.photobooking.util;

import com.photobooking.model.photographer.Photographer;
import java.util.List;
import java.util.ArrayList;
import java.util.Comparator;

/**
 * Enhanced sorting utility for the Event Photography System
 * Provides optimized implementations of sorting algorithms
 */
public class EnhancedSortingUtility {

    /**
     * Optimized Bubble Sort implementation for sorting photographers by rating
     * Includes early termination if no swaps are made in a pass
     *
     * @param photographerList List of photographers to sort
     * @param ascending If true, sort in ascending order; otherwise, sort in descending order
     * @return Sorted list of photographers
     */
    public static List<Photographer> bubbleSortByRating(List<Photographer> photographerList, boolean ascending) {
        if (photographerList == null || photographerList.isEmpty()) {
            return new ArrayList<>();
        }

        // Create a copy of the list to avoid modifying the original
        List<Photographer> sortedList = new ArrayList<>(photographerList);
        int n = sortedList.size();
        boolean swapped;

        System.out.println("Starting bubble sort for " + n + " photographers");

        // Track the number of swaps for performance analysis
        int swapCount = 0;

        // Track the number of iterations for performance analysis
        int iterations = 0;

        for (int i = 0; i < n - 1; i++) {
            swapped = false;

            // Optimization: In each iteration, the last i elements are already in place
            for (int j = 0; j < n - i - 1; j++) {
                iterations++;
                boolean shouldSwap;
                if (ascending) {
                    shouldSwap = sortedList.get(j).getRating() > sortedList.get(j + 1).getRating();
                } else {
                    shouldSwap = sortedList.get(j).getRating() < sortedList.get(j + 1).getRating();
                }

                if (shouldSwap) {
                    // Swap elements
                    Photographer temp = sortedList.get(j);
                    sortedList.set(j, sortedList.get(j + 1));
                    sortedList.set(j + 1, temp);
                    swapped = true;
                    swapCount++;
                }
            }

            // Optimization: If no swapping occurred in this pass, array is sorted
            if (!swapped) {
                System.out.println("Early termination after " + (i+1) + " passes");
                break;
            }
        }

        System.out.println("Bubble sort completed with " + swapCount + " swaps and " + iterations + " comparisons");

        return sortedList;
    }

    /**
     * Optimized Bubble Sort implementation for sorting photographers by name
     * Includes early termination if no swaps are made in a pass
     *
     * @param photographerList List of photographers to sort
     * @param ascending If true, sort in ascending order; otherwise, sort in descending order
     * @return Sorted list of photographers
     */
    public static List<Photographer> bubbleSortByName(List<Photographer> photographerList, boolean ascending) {
        if (photographerList == null || photographerList.isEmpty()) {
            return new ArrayList<>();
        }

        // Create a copy of the list to avoid modifying the original
        List<Photographer> sortedList = new ArrayList<>(photographerList);
        int n = sortedList.size();
        boolean swapped;

        for (int i = 0; i < n - 1; i++) {
            swapped = false;

            for (int j = 0; j < n - i - 1; j++) {
                String name1 = sortedList.get(j).getBusinessName() != null ?
                        sortedList.get(j).getBusinessName().toLowerCase() : "";
                String name2 = sortedList.get(j + 1).getBusinessName() != null ?
                        sortedList.get(j + 1).getBusinessName().toLowerCase() : "";

                boolean shouldSwap;
                if (ascending) {
                    shouldSwap = name1.compareTo(name2) > 0;
                } else {
                    shouldSwap = name1.compareTo(name2) < 0;
                }

                if (shouldSwap) {
                    // Swap elements
                    Photographer temp = sortedList.get(j);
                    sortedList.set(j, sortedList.get(j + 1));
                    sortedList.set(j + 1, temp);
                    swapped = true;
                }
            }

            // Optimization: If no swapping occurred in this pass, array is sorted
            if (!swapped) {
                break;
            }
        }

        return sortedList;
    }

    /**
     * Optimized Bubble Sort implementation for sorting photographers by price
     * Includes early termination if no swaps are made in a pass
     *
     * @param photographerList List of photographers to sort
     * @param ascending If true, sort in ascending order; otherwise, sort in descending order
     * @return Sorted list of photographers
     */
    public static List<Photographer> bubbleSortByPrice(List<Photographer> photographerList, boolean ascending) {
        if (photographerList == null || photographerList.isEmpty()) {
            return new ArrayList<>();
        }

        // Create a copy of the list to avoid modifying the original
        List<Photographer> sortedList = new ArrayList<>(photographerList);
        int n = sortedList.size();
        boolean swapped;

        for (int i = 0; i < n - 1; i++) {
            swapped = false;

            for (int j = 0; j < n - i - 1; j++) {
                boolean shouldSwap;
                if (ascending) {
                    shouldSwap = sortedList.get(j).getBasePrice() > sortedList.get(j + 1).getBasePrice();
                } else {
                    shouldSwap = sortedList.get(j).getBasePrice() < sortedList.get(j + 1).getBasePrice();
                }

                if (shouldSwap) {
                    // Swap elements
                    Photographer temp = sortedList.get(j);
                    sortedList.set(j, sortedList.get(j + 1));
                    sortedList.set(j + 1, temp);
                    swapped = true;
                }
            }

            // Optimization: If no swapping occurred in this pass, array is sorted
            if (!swapped) {
                break;
            }
        }

        return sortedList;
    }

    /**
     * Generic bubble sort implementation for sorting photographers by any comparable property
     *
     * @param <T> Type of the sorting key
     * @param photographerList List of photographers to sort
     * @param comparator Comparator to determine the sorting order
     * @return Sorted list of photographers
     */
    public static <T extends Comparable<T>> List<Photographer> bubbleSort(
            List<Photographer> photographerList,
            Comparator<Photographer> comparator) {

        if (photographerList == null || photographerList.isEmpty()) {
            return new ArrayList<>();
        }

        // Create a copy of the list to avoid modifying the original
        List<Photographer> sortedList = new ArrayList<>(photographerList);
        int n = sortedList.size();
        boolean swapped;

        for (int i = 0; i < n - 1; i++) {
            swapped = false;

            for (int j = 0; j < n - i - 1; j++) {
                if (comparator.compare(sortedList.get(j), sortedList.get(j + 1)) > 0) {
                    // Swap elements
                    Photographer temp = sortedList.get(j);
                    sortedList.set(j, sortedList.get(j + 1));
                    sortedList.set(j + 1, temp);
                    swapped = true;
                }
            }

            // Optimization: If no swapping occurred in this pass, array is sorted
            if (!swapped) {
                break;
            }
        }

        return sortedList;
    }
}
