////
//// Created by Diego Urgell on 16/06/21.
////

#include <limits>
#include "DistributionInterface.cpp"

class Segment {

public:

    int start, mid, end;
    double bestDecrease, costNoSplit;
    bool invalidatesAfter;
    int invalidatesIndex; // TODO
    std::shared_ptr<Distribution> dist;

public:

    Segment(int start, int end, std::shared_ptr<Distribution> dist){
        this -> start = start;
        this -> end = end;
        this -> mid = 0;
        this -> dist = dist;
        this -> costNoSplit = this -> dist -> costFunction(start, end);
        this -> optimalPartition();
    }

    // To calculate the optimal partition in a segment and
    void optimalPartition(){
        double bestSplitCost = std::numeric_limits<double>::max(), currSplitCost;
        for(int i = this -> start + 1; i < this -> end; i++){
            currSplitCost = this -> dist -> getCost(this -> start, i, this -> end);
            if (currSplitCost < bestSplitCost){
                bestSplitCost = currSplitCost;
                this -> mid = i;
            }
            int t = this -> mid;
            t = t + 1;
        }
        this -> bestDecrease = bestSplitCost - this -> costNoSplit;
    }

    friend bool operator < (const Segment& l, const Segment& r){
        return l.bestDecrease < r.bestDecrease;
    }

};