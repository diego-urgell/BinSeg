//
// Created by Diego Urgell on 23/06/21.
//

#include "GenericFactory.cpp"
#include "Cumsum.cpp"
#include <set>

class Distribution{

public:

    std::shared_ptr<Cumsum> cumsum;

    Distribution() = default;

    ~Distribution() = default;

    virtual double costFunction(int start, int end) = 0;

    virtual void setCumsum(){
        cumsum = std::make_shared<CumsumSquared>();
    }

    double getCost(int start, int mid, int end){
        double first = this -> costFunction(start, mid);
        double second = this -> costFunction(mid+1, end);
        return first + second;
    }
};

class DistributionFactory: public GenericFactory<Distribution>{
    void foo(){regSpecs;}
};