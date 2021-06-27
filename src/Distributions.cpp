//
// Created by Diego Urgell on 10/06/21.
//

#include "Algorithms.cpp"

#define DISTRIBUTION(SUBCLASS, BODY) \
    class SUBCLASS: public Distribution, public Registration<SUBCLASS, Distribution, DistributionFactory> { \
    public:                                                                                                 \
        inline static std::string factoryName = TO_STRING(SUBCLASS);                                        \
        SUBCLASS(){is_registered;}                                                                          \
        BODY                                                                                                \
    };


DISTRIBUTION(NormMean,
    void setCumsum(){
        this -> cumsum = std::make_shared<Cumsum>();
    }
    double costFunction(int start, int end){
        double lSum = this -> cumsum -> getLinearSum(start, end);
        double N = end - start + 1;
        return - pow(lSum, 2)/N;
    }
)


DISTRIBUTION(NormVar,
    double costFunction(int start, int end){

    }
)


DISTRIBUTION(NormMeanVar,
    double costFunction(int start, int end){

    }
)


DISTRIBUTION(Poisson,
    double costFunction(int start, int end){

    }
)


DISTRIBUTION(Negbin,
    double costFunction(int start, int end){

    }
)


DISTRIBUTION(Exponential,
    double costFunction(int start, int end){

    }
)