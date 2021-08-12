//
// Created by Diego Urgell on 16/06/21.
//

#include <limits>
#include "DistributionInterface.cpp"

/**
 * This class represents a segment that is to be partitioned. It finds the optimal partition in terms of the cost decrease
 * produced by the two newly created segments, and stores the best_decrease and the changepoint.
 */
class Segment {

public:

    int start, mid, end, minSegLen;
    double bestDecrease, costNoSplit;
    int invalidatesIndex, invalidatesAfter;
    std::shared_ptr<Distribution> dist; // In order to calculate the costs.

public:

    /**
     * A segment initialization requires the start and end indexes, as well as the distribution that contains the methods
     * to compute the cost of a partition.
     * @param start inclusive
     * @param end inclusive
     * @param dist A Distribution pointer to get the cost of partition.
     */
    Segment(int start, int end, std::shared_ptr<Distribution> dist, int minSegLen, int invalidatesAfter, int invalidatesIndex){
        this -> start = start;
        this -> end = end;
        this -> mid = 0;
        this -> dist = dist;
        this -> minSegLen = minSegLen;
        this -> costNoSplit = this -> dist -> costFunction(start, end); // The cost of the whole segment
        this -> optimalPartition(); // Immediately find the best partition
        this -> invalidatesAfter = invalidatesAfter;
        this -> invalidatesIndex = invalidatesIndex;
    }

    /**
     * In this method, the changepoint whose segmentation produces the best decrease in cost is identified. It
     * iterates over every possible changepoint and computes the cost of the two segments using the Distribution::getCost
     * function. At the end, it computes the bestDecrease.
     */
    void optimalPartition(){
        double bestSplitCost = std::numeric_limits<double>::max(), currSplitCost;
        for(int i = this -> start + minSegLen; i <= this -> end - this -> minSegLen; i++){
            currSplitCost = this -> dist -> getCost(this -> start, i, this -> end);
            if (currSplitCost == INFINITY){
                this -> mid = 0;
                bestSplitCost = INFINITY;
                break;
            }
            if (currSplitCost < bestSplitCost){
                bestSplitCost = currSplitCost;
                this -> mid = i;
            }
        }
        this -> bestDecrease = this -> costNoSplit - bestSplitCost;
    }

    /**
     * Overrides the < operator so that objects are compared by their bestDecrease. This is necessary for the multiset
     * to appropriately order to Segments, so that the first one is always the one with the optimal cost decrease.
     * @param l Segment object
     * @param r Segment object
     * @return bool
     */
    friend bool operator < (const Segment& l, const Segment& r){
        return l.bestDecrease > r.bestDecrease;
    }

};