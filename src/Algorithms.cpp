//
// Created by Diego Urgell on 10/06/21.
//

#include "AlgorithmInterface.cpp"

class BinarySegmentation: public Algorithm, public Registration<BinarySegmentation, Algorithm, AlgorithmFactory>{

public:

    inline static std::string factoryName = "BS";

    BinarySegmentation(){ is_registered; }

    void binseg(){
        this -> candidates.emplace(0, this -> length-1, this -> dist);
        for(int i = 0; i < this -> numCpts; i++){
            auto optCpt = this -> candidates.begin();
            this -> changepoints[i] = optCpt -> mid;
            this -> candidates.emplace(optCpt -> start, optCpt -> mid, this -> dist);
            this -> candidates.emplace(optCpt -> mid + 1, optCpt -> end, this -> dist);
            this -> candidates.erase(optCpt);
        }
    }
};

class SeedBS: public Algorithm, public Registration<SeedBS, Algorithm, AlgorithmFactory> {

public:

    inline static std::string factoryName = "SeedBS";
};

class WildBS: public Algorithm, public Registration<WildBS, Algorithm, AlgorithmFactory>{
public:

    inline static std::string factoryName = "WildBS";

};
