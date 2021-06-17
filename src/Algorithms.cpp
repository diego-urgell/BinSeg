//
// Created by Diego Urgell on 10/06/21.
//

#include "Interfaces.cpp"

class BinarySegmentation: public Algorithm, public Registration<BinarySegmentation, Algorithm, AlgorithmFactory>{

public:

    inline static std::string factoryName = "BS";

    BinarySegmentation(){is_registered;}

    void binseg(double *data, int length, double *ans){
        this -> dist -> cumsum -> init(data, length);
        for(int i = 0; i < 5; i++){
            ans[i] = this -> dist -> cumsum ->getLinearSum(0, i);
        }
    }
};

class SeedBS: public Algorithm, public Registration<SeedBS, Algorithm, AlgorithmFactory>{

public:

    inline static std::string factoryName = "SeedBS";
};

class WildBS: public Algorithm, public Registration<WildBS, Algorithm, AlgorithmFactory>{
public:

    inline static std::string factoryName = "WildBS";
};
