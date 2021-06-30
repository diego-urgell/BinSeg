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
        return 5;
    }
)

class NormMeanVar: public Distribution, public Registration<NormMeanVar, Distribution, DistributionFactory> {
    public:

    inline static std::string factoryName = "NormMeanVar";
    NormMeanVar(){(void) is_registered;}

    double costFunction(int start, int end){
        double lSum =  this -> cumsum -> getLinearSum(start, end);
        double sSum =  this -> cumsum -> getQuadraticSum(start, end);
        int N = end - start + 1;
//        double mean = lSum/N;
        double var = (sSum - (lSum*lSum/N))/N;
        if(var <= 0){  // Making sure the variance is not zero, so that the log does not raise an exception
            var = 0.00000000001;
        }
        double cost = N*(log(var) + log(2*M_PI) + 1);
        return cost;
    }
    };


//DISTRIBUTION(NormMeanVar,
//    double costFunction(int start, int end){
//        double lSum =  this -> cumsum -> getLinearSum(start, end);
//        double sSum =  this -> cumsum -> getQuadraticSum(start, end);
//        int N = end - start + 1;
//        double mean = lSum/N;
//        double var = (sSum - (lSum*lSum/N))/N;
//        if(var <= 0){  // Making sure the variance is not zero, so that the log does not raise an exception
//            var = 0.00000000001;
//        }
//        return -N*(log(var) + log(2*M_PI) + 1);
//    }
//)


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