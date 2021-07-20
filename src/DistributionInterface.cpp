//
// Created by Diego Urgell on 23/06/21.
//

#include "GenericFactory.cpp"
#include "Cumsum.cpp"
#include <set>

/**
 * This is an abstract class, that works as an interface for any of the distribution subclasses. Every one of them must
 * implement the costFunction method, which is pure virtual. Furthermore, the setCumsum method can be overridden in case
 * a particular distribution only requires the Linear Cumsum class.
 */
class Distribution{

public:

    std::shared_ptr<Cumsum> summaryStatistics; // Pointer to Cumsum object, which may also be CumsumSquared

    Distribution() = default;

    virtual ~Distribution() = default;

    /**
     * This method creates the setCumsum, and it should be called in order to initialize the Distribution object. Note
     * that this does not initialize the summaryStatistics, since the data is not yet provided.
     */
    virtual void setCumsum(){
        summaryStatistics = std::make_shared<CumsumSquared>();
    }

    /**
     * This is the specific implementation of the cost function, and it completely depends on each of the distributions.
     * It is key method of this interface and should be implemented by any subclass. It calculates the cost of a segment
     * given start and end indexes. Note that the summaryStatistics object must have been initialized first (see Algorithm::init())
     * For the implementation, you must provide the negative log-likelihood of the specific distribution,
     * @param start inclusive
     * @param end inclusive
     * @return The cost of the segment fom start to end.
     */
    virtual double costFunction(int start, int end) = 0;

    /**
     * This is a wrapper method to get the cost of a particular segmentation. It is useful to get the cost of splitting
     * a segment in two halves. It calculates first the cost of the left and right partitions, and then adds them up.
     * @param start inclusive
     * @param mid index of the partition
     * @param end inclusive
     * @return Cost of the partition (rather than only one segment)
     */
    double getCost(int start, int mid, int end){
        double first = this -> costFunction(start, mid);
        double second = this -> costFunction(mid+1, end);
        double total = first + second;
        return total;
    }

    virtual void calcParams(int start, int mid, int end, int i, double * params_mat, int cpts) = 0;

    virtual std::vector<std::string> getParamNames() = 0;

    virtual int getParamCount() = 0;

};

/**
 * This class implements the GenericFactory interface for the Distribution interface. It exists only to instantiate the
 * template, and initialize and store the mapping of registered classes.
 */
class DistributionFactory: public GenericFactory<Distribution>{
    void foo(){(void)regSpecs;}
};