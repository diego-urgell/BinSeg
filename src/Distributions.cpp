//
// Created by Diego Urgell on 10/06/21.
//

#include "Algorithms.cpp"

#define DISTRIBUTION(SUBCLASS, BODY) \
    class SUBCLASS: public Distribution, public Registration<SUBCLASS, Distribution, DistributionFactory> { \
    public:                                                                                                 \
        static std::string factoryName;                                        \
        static std::vector<std::string> param_names;                                                        \
        SUBCLASS(){(void) created;}                                                                   \
        BODY                                                                                                \
    };


DISTRIBUTION(mean_norm,

    static std::string description;

    void setCumsum(){
        this -> summaryStatistics = std::make_shared<Cumsum>();
    }

    double costFunction(int start, int end){
        double lSum = this -> summaryStatistics -> getLinearSum(start, end);
        double N = end - start + 1;
        return - pow(lSum, 2)/N;
    }

    void calcParams(int start, int mid, int end, int i,  double * param_mat, int cpts){
        param_mat[i + cpts * 5] = this -> summaryStatistics -> getMean(start, mid);
        param_mat[i + cpts * 6] = this->summaryStatistics->getMean(mid + 1, end);
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

    static std::string description;

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
        param_mat[i + cpts * 5] = sqrt(varLeft / (mid - start + 1));
        param_mat[i + cpts * 6] = sqrt(varRight / (end - mid + 1));
    }

    std::vector<std::string> getParamNames(){
        return var_norm::param_names;
    }

    int getParamCount(){
        return 2;
    }

)

DISTRIBUTION(meanvar_norm,

    static std::string description;

    double costFunction(int start, int end){
        double lSum =  this -> summaryStatistics -> getLinearSum(start, end);
        double sSum =  this -> summaryStatistics -> getQuadraticSum(start, end);
        int N = end - start + 1;
        double varN = (sSum - (lSum*lSum/N));
        if(varN <= 0) return INFINITY;
        return N*(log(varN/N) + log(2*M_PI) + 1);
    }

    void calcParams(int start, int mid, int end, int i,  double * param_mat, int cpts){
        double meanLeft = this -> summaryStatistics -> getMean(start, mid);
        double meanRight = this -> summaryStatistics -> getMean(mid + 1, end);
        double varLeft = this -> summaryStatistics -> getVarianceN(start, mid, false);
        double varRight = this -> summaryStatistics -> getVarianceN(mid + 1, end, false);

        param_mat[i + cpts * 5] = meanLeft;
        param_mat[i + cpts * 6] = meanRight;
        param_mat[i + cpts * 7] = varLeft / (mid - start + 1);
        param_mat[i + cpts * 8] = varRight / (end - mid + 1);
    }

    std::vector<std::string> getParamNames(){
        return meanvar_norm::param_names;
    }

    int getParamCount(){
        return 4;
    }
)

DISTRIBUTION(negbin,

    static std::string description;

    double costFunction(int start, int end){
        double lSum = this -> summaryStatistics -> getLinearSum(start, end);
        double mean = this -> summaryStatistics -> getMean(start, end);
        double varN = this -> summaryStatistics -> getVarianceN(start, end, false);
        int N = end - start + 1;
        if (varN <= 0) return INFINITY;
        double var = varN/N;
        double r_dispersion = fabs(pow(mean, 2)/(var-mean));
        double p_success = mean/var;
        return (lSum * log(1-p_success) + N * r_dispersion * log(p_success));
    }

    void calcParams(int start, int mid, int end, int i, double * param_mat, int cpts){
        double meanLeft = this -> summaryStatistics -> getMean(start, mid);
        double meanRight = this -> summaryStatistics -> getMean(mid + 1, end);
        double varLeft = this -> summaryStatistics -> getVarianceN(start, mid, false)/(mid - start + 1);
        double varRight = this -> summaryStatistics -> getVarianceN(mid + 1, end, false)/(end - mid + 1);
        double probLeft = meanLeft/varLeft;
        double probRight = meanRight/varRight;

        param_mat[i + cpts * 5] = probLeft;
        param_mat[i + cpts * 6] = probRight;
    }

    std::vector<std::string> getParamNames(){
        return negbin::param_names;
    }

    int getParamCount(){
        return 2;
    }
)


DISTRIBUTION(poisson,

    static std::string description;

    double costFunction(int start, int end){
        double lSum = this -> summaryStatistics -> getLinearSum(start, end);
        int N = end - start + 1;
        return - lSum * (log(lSum) - log(N));
    }

    void calcParams(int start, int mid, int end, int i, double * param_mat, int cpts){
        double rateLeft = this -> summaryStatistics -> getMean(start, mid);
        double rateRight = this -> summaryStatistics -> getMean(mid + 1, end);

        param_mat[i + cpts * 5] = rateLeft;
        param_mat[i + cpts * 6] = rateRight;
    }

    std::vector<std::string> getParamNames(){
        return poisson::param_names;
    }

    int getParamCount(){
        return 2;
    }
)


DISTRIBUTION(exponential,

    void setCumsum(){
        this -> summaryStatistics = std::make_shared<Cumsum>();
    }

    static std::string description;

    double costFunction(int start, int end){
        int T = end - start + 1;
        double lSum = this -> summaryStatistics -> getLinearSum(start, end);
        return - T * (log(T) - log(lSum)); // -1 -> -T on R code
    }

    void calcParams(int start, int mid, int end, int i, double * param_mat, int cpts){
        double lSumLeft = this -> summaryStatistics -> getLinearSum(start, mid);
        double lSumRight = this -> summaryStatistics -> getLinearSum(mid + 1, end);
        double rateLeft = lSumLeft == INFINITY? INFINITY : (mid - start + 1) / lSumLeft;
        double rateRight = lSumRight == INFINITY? INFINITY : (end - mid + 1) / lSumRight;

        param_mat[i + cpts * 5] = rateLeft;
        param_mat[i + cpts * 6] = rateRight;
    }

    std::vector<std::string> getParamNames(){
        return poisson::param_names;
    }

    int getParamCount(){
        return 2;
    }
)