//
// Created by Diego Urgell on 16/06/21.
//


#include "Segment.cpp"

/**
 * Abstract class that is an interface to every specific algorithm based on BinarySegmentation. It contains the basic
 * attributes as the distribution, the multiset of candidates, and the vector of changepoints.
 */
class Algorithm{

public:

    std::shared_ptr<Distribution> dist;
    std::multiset<Segment> candidates;
    int length, numCpts;
    int * changepoints;


public:

    Algorithm() = default;

    virtual ~Algorithm() = default;

    /**
     * This is the most important method, that implements the algorithm per se. It must be overriden in every specific
     * algorithm subclass.
     */
    virtual void binseg() = 0;

    /**
     * This initialization method copies the necessary data into the class' attributes in order to use them later on
     * in the binseg method.
     * @param data The vector of data, given by the user. Used to initialize the cumsums.
     * @param length The length of the data vector
     * @param numCpts  The number of changepoints to be computed
     * @param dist The distribution pointer to compute the costs.
     * @param changepoints The changepoints NumericVector.
     */
    void init(double *data, int length, int numCpts, std::shared_ptr<Distribution> dist, int * changepoints){
        this -> dist = dist;
        this -> dist -> cumsum -> init(data, length);
        this -> length = length;
        this -> numCpts = numCpts;
        this -> changepoints = changepoints;
    }
};

/**
 * Instantiation of the GenericFactory template for the Algorithm interface.
 */
class AlgorithmFactory: public GenericFactory<Algorithm>{
    void foo(){(void)regSpecs;}
};
