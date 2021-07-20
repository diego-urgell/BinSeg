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

    static std::vector<std::string> param_names;

    void setCumsum(){
        this -> summaryStatistics = std::make_shared<Cumsum>();
    }

    double costFunction(int start, int end){
        double lSum = this -> summaryStatistics -> getLinearSum(start, end);
        double N = end - start + 1;
        return - pow(lSum, 2)/N;
    }

    void calcParams(int start, int mid, int end, int i,  double * param_mat, int cpts){
        param_mat[i + cpts * 4] = this -> summaryStatistics -> getMean(start, mid);
        param_mat[i + cpts * 5] = this -> summaryStatistics -> getMean(mid + 1, end);
    }

    std::vector<std::string> getParamNames(){
        std::vector<std::string> names =  mean_norm::param_names;
        return names;
    }

    int getParamCount(){
        return 2;
    }
)


DISTRIBUTION(var_norm,
    static std::vector<std::string> param_names;

    double costFunction(int start, int end){
        double lSum = this -> summaryStatistics -> getLinearSum(start, end);
        double sSum =  this -> summaryStatistics -> getQuadraticSum(start, end);
        int N = end - start + 1;
        double mean = this -> summaryStatistics -> getTotalMean(); // Fixed mean
        double varN = (sSum - 2 * mean * lSum + N * pow(mean, 2)); // Variance of segment.
        if(varN <= 0) return INFINITY;
        return N * (log(2*M_PI) + log(varN/N) + 1);
    }

    void calcParams(int start, int mid, int end, int i,  double * param_mat, int cpts){
        double varLeft = this -> summaryStatistics -> getVarianceN(start, mid, true);
        double varRight = this -> summaryStatistics -> getVarianceN(mid + 1, end, true);
        param_mat[i + cpts * 4] = sqrt(varLeft / (mid - start + 1));
        param_mat[i + cpts * 5] = sqrt(varRight / (end - mid + 1));
    }

    std::vector<std::string> getParamNames(){
        return var_norm::param_names;
    }

    int getParamCount(){
        return 2;
    }

)

DISTRIBUTION(meanvar_norm,
    static std::vector<std::string> param_names;

    double costFunction(int start, int end){
        double lSum =  this -> summaryStatistics -> getLinearSum(start, end);
        double sSum =  this -> summaryStatistics -> getQuadraticSum(start, end);
        int N = end - start + 1;
        double var = (sSum - (lSum*lSum/N))/N;
        if(var <= 0) return INFINITY;
        return N*(log(var) + log(2*M_PI) + 1);
    }

    void calcParams(int start, int mid, int end, int i,  double * param_mat, int cpts){
        double meanLeft = this -> summaryStatistics -> getMean(start, mid);
        double meanRight = this -> summaryStatistics -> getMean(mid + 1, end);
        double varLeft = this -> summaryStatistics -> getVarianceN(start, mid, false);
        double varRight = this -> summaryStatistics -> getVarianceN(mid + 1, end, false);

        param_mat[i + cpts * 4] = meanLeft;
        param_mat[i + cpts * 5] = meanRight;
        param_mat[i + cpts * 6] = sqrt(varLeft / (mid - start + 1));
        param_mat[i + cpts * 7] = sqrt(varRight / (end - mid + 1));
    }

    std::vector<std::string> getParamNames(){
        return meanvar_norm::param_names;
    }

    int getParamCount(){
        return 4;
    }
)

//
//DISTRIBUTION(Poisson,
//    double costFunction(int start, int end){
//        return 5;
//    }
//
//    std::vector<std::vector<double>>  retParams(){
//        std::vector<std::vector<double>> params;
//        return params;
//    }
//)
//
//
//DISTRIBUTION(Negbin,
//    double costFunction(int start, int end){
//        return 5;
//    }
//
//            std::vector<std::vector<double>>  retParams(){
//                std::vector<std::vector<double>> params;
//                return params;
//            }
//)
//
//
//DISTRIBUTION(Exponential,
//    double costFunction(int start, int end){
//        return 5;
//    }
//
//            std::vector<std::vector<double>>  retParams(){
//                std::vector<std::vector<double>> params;
//                return params;
//            }
//)