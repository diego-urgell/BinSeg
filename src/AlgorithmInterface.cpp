//
// Created by Diego Urgell on 16/06/21.
//


#include "Segment.cpp"

class Algorithm{

public:

    std::shared_ptr<Distribution> dist;
    std::multiset<Segment> candidates;
    int length, numCpts;
    int * changepoints;


public:

    Algorithm() = default;

    ~Algorithm() = default;

    virtual void binseg() = 0;

    void init(double *data, int length, int numCpts, std::shared_ptr<Distribution> dist, int * changepoints){
        this -> dist = dist;
        this -> dist -> cumsum -> init(data, length);
        this -> length = length;
        this -> numCpts = numCpts;
        this -> changepoints = changepoints;
    }
};


class AlgorithmFactory: public GenericFactory<Algorithm>{
    void foo(){regSpecs;}
};



