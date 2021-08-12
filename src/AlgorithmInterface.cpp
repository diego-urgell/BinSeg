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
    int length, numCpts, minSegLen;
    double * param_mat;

public:

    Algorithm() = default;

    virtual ~Algorithm() = default;

    /**
     * This initialization method copies the necessary data into the class' attributes in order to use them later on
     * in the binseg method.
     * @param data The vector of data, given by the user. Used to initialize the summaryStatisticss.
     * @param length The length of the data vector
     * @param numCpts  The number of changepoints to be computed
     * @param dist The distribution pointer to compute the costs.
     * @param changepoints The changepoints NumericVector.
     */
    void init(double *data, int length, int numCpts, std::shared_ptr<Distribution> dist, int minSegLen, double * param_mat){
        this -> dist = dist;
        this -> length = length;
        this -> numCpts = numCpts;
        this -> minSegLen = minSegLen;
        this -> param_mat = param_mat;
        this -> dist -> summaryStatistics -> init(data, length);
    }

    /**
     * This is the most important method, that implements the algorithm per se. It must be overridden in every specific
     * algorithm subclass.
     */
    virtual void binseg() = 0;

    virtual std::vector<std::string> getParamNames() = 0;

};


/**
 * Instantiation of the GenericFactory template for the Algorithm interface.
 */
class AlgorithmFactory: public GenericFactory<Algorithm>{
    void foo(){regSpecs = std::map<std::string, std::shared_ptr<Algorithm>(*)()>();}
};
