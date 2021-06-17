//
// Created by Diego Urgell on 16/06/21.
//

#include "GenericFactory.cpp"
#include "Cumsum.cpp"
#include "Segment.cpp"
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


};


class Algorithm{

public:

    std::shared_ptr<Distribution> dist;
    std::multiset<Segment> candidates;

public:

    Algorithm() = default;

    ~Algorithm() = default;

    virtual void binseg(double *data, int length, double *ans) = 0;

    void init(std::shared_ptr<Distribution> dist){
        this -> dist = dist;
    }
};


class AlgorithmFactory: public GenericFactory<Algorithm>{
    void foo(){regSpecs;}
};


class DistributionFactory: public GenericFactory<Distribution>{
    void foo(){regSpecs;}
};
