//
// Created by Diego Urgell on 10/06/21.
//

#include "Algorithms.cpp"

class NormMean: public Distribution, public Registration<NormMean, Distribution, DistributionFactory>{

public:

    inline static std::string factoryName = "NormMean";

    NormMean(){is_registered;} // CRITICAL LINE, otherwise it does not register

    void setCumsum(){
        this -> cumsum = std::make_shared<Cumsum>();
    }

    double costFunction(int start, int end){
        double lSum = this -> cumsum -> getLinearSum(start, end);
        double N = end - start + 1;
        return - pow(lSum, 2)/N;
    }
};

class NormVar:  public Distribution, public Registration<NormVar, Distribution, DistributionFactory>{
public:

    inline static std::string factoryName = "NormVar";
};

class NormMeanVar:  public Distribution, public Registration<NormMeanVar, Distribution, DistributionFactory>{
public:

    inline static std::string factoryName = "NormMeanVar";
};

class Poisson: public Distribution, public Registration<Poisson, Distribution, DistributionFactory>{
public:

    inline static std::string factoryName = "Poisson";
};

class NegBin:  public Distribution, public Registration<NegBin, Distribution, DistributionFactory>{
public:

    inline static std::string factoryName = "NegBin";
};


class Exponential:  public Distribution, public Registration<Exponential, Distribution, DistributionFactory>{
public:

    inline static std::string factoryName = "Exp";
};
