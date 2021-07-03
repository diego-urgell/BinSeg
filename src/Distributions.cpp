//
// Created by Diego Urgell on 10/06/21.
//

#include "Algorithms.cpp"

#define DISTRIBUTION(SUBCLASS, BODY) \
    class SUBCLASS: public Distribution, public Registration<SUBCLASS, Distribution, DistributionFactory> { \
    public:                                                                                                 \
        inline static std::string factoryName = TO_STRING(SUBCLASS);                                        \
        SUBCLASS(){(void) is_registered;}                                                                          \
        BODY                                                                                                \
    };


DISTRIBUTION(mean_norm,
    void setCumsum(){
        this -> cumsum = std::make_shared<Cumsum>();
    }
    double costFunction(int start, int end){
        double lSum = this -> cumsum -> getLinearSum(start, end);
        double N = end - start + 1;
        return - pow(lSum, 2)/N;
    }
)


DISTRIBUTION(var_norm,
    double costFunction(int start, int end){
        double lSum = this -> cumsum -> getLinearSum(start, end);
        double sSum =  this -> cumsum -> getQuadraticSum(start, end);
        int N = end - start + 1;
        double mean = this -> cumsum -> getTotalMean(); // Fixed mean
        double varN = (sSum - 2 * mean * lSum + N * pow(mean, 2)); // Variance of segment.
        if(varN <= 0){  // Making sure the variance is not zero, so that the log does not raise an exception
            varN = 0.00000000001;
        }
        return N * (log(2*M_PI) + log(varN/N) + 1);
    }
)

DISTRIBUTION(meanvar_norm,
    double costFunction(int start, int end){
        double lSum =  this -> cumsum -> getLinearSum(start, end);
        double sSum =  this -> cumsum -> getQuadraticSum(start, end);
        int N = end - start + 1;
        double var = (sSum - (lSum*lSum/N))/N;
        if(var <= 0){  // Making sure the variance is not zero, so that the log does not raise an exception
            var = 0.00000000001;
        }
        return N*(log(var) + log(2*M_PI) + 1);
    }
)


DISTRIBUTION(Poisson,
    double costFunction(int start, int end){
        return 5;
    }
)


DISTRIBUTION(Negbin,
    double costFunction(int start, int end){
        return 5;
    }
)


DISTRIBUTION(Exponential,
    double costFunction(int start, int end){
        return 5;
    }
)