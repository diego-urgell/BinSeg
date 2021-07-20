//
// Created by Diego Urgell on 10/06/21.
//

#include "AlgorithmInterface.cpp"

// Double Expansion Trick to transform the name of a class into a string.
#define STRINGIZE(x) #x
#define TO_STRING(x) STRINGIZE(x)

// This is the structure that every specific distribution class must have. In order to avoid repetition in the classes
// definition, this Macro handles the expansion of the code given only the name of the SUBCLASS (which is the name of the
// algorithm), and the BODY, (which is the specific implementation of the binseg method). The TO_STRING Macro is used
// in order to register the algorithm in the factory using the class name. Also, in the construtor, the boolean
// is_registered from Registration class is called in order to instantiate the template.
#define ALGORITHM(SUBCLASS, BODY) \
    class SUBCLASS: public Algorithm, public Registration<SUBCLASS, Algorithm, AlgorithmFactory> {          \
    public:                                                                                                 \
        inline static std::string factoryName = TO_STRING(SUBCLASS);                                        \
        SUBCLASS(){(void) is_registered;}                                                                   \
        BODY                                                                                                \
    };


ALGORITHM(BS,
    /**
     * For regular Binary Segmentation, first the whole segment is created and pushed into the candidates multiset.
     * Given the behaviour of a Segment object, just after it is created, the optimal partition is computed and stored as
     * Segment::mid, along with the decrease in cost that this optimal changepoint produces. Given that the Segments are
     * stored in a multiset, and the ordering key is the best_decrease, it is guaranteed that the first element in the
     * set will always be the optimal partition. To find more segments, just find the best split, store the info, and add
     * to the candidates multiset the two newly created segments.
     */
     static std::vector<std::string> param_names;

     void binseg(){
         this -> candidates.emplace(0, this -> length-1, this -> dist, this -> minSegLen);
         int sep = this -> numCpts + 1;
         this -> param_mat[0] = this -> length;
         this -> param_mat[sep] = 0;
         this -> param_mat[sep * 2] = 0;
         this -> param_mat[sep * 3] = this -> dist -> costFunction(0, this -> length - 1);
         for(int i = 1; i <= this -> numCpts; i++){
             std::multiset<Segment>::iterator optCpt = this -> candidates.begin();
             if (optCpt -> mid == 0) return;
             this -> param_mat[i] = optCpt -> mid + 1;
             this -> param_mat[sep + i] = 0;
             this -> param_mat[sep * 2 + i] = 0;
             this -> param_mat[sep * 3 + i] = param_mat[sep * 3 + i - 1] - optCpt -> bestDecrease;
             this -> dist -> calcParams(optCpt -> start, optCpt -> mid, optCpt -> end, i, this -> param_mat, sep);
             this -> candidates.emplace(optCpt -> start, optCpt -> mid, this -> dist, this -> minSegLen);
             this -> candidates.emplace(optCpt -> mid + 1, optCpt -> end, this -> dist, this -> minSegLen);
             this -> candidates.erase(optCpt);
         }
     }

     std::vector<std::string> getParamNames(){
         std::vector<std::string> names = BS::param_names;
         std::vector<std::string> param_names = this -> dist -> getParamNames();
         names.insert(names.end(), param_names.begin(), param_names.end());
         return names;
     }
)


//ALGORITHM(SeedBS,
//    void binseg(){
//
//    }
//)
//
//
//ALGORITHM(WildBS,
//    void binseg(){
//
//    }
//)
