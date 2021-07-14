//
// Created by Diego Urgell on 10/06/21.
//

#include "Algorithms.cpp"

#define INF std::numeric_limits<double>::max()

#define DISTRIBUTION(SUBCLASS, BODY) \
    class SUBCLASS: public Distribution, public Registration<SUBCLASS, Distribution, DistributionFactory> { \
    public:                                                                                                 \
        inline static std::string factoryName = TO_STRING(SUBCLASS);                                        \
        SUBCLASS(){(void) is_registered;}                                                                          \
        BODY                                                                                                \
    };


DISTRIBUTION(mean_norm,
    std::vector<double> before_mean;
    std::vector<double> after_mean;
    static std::vector<std::string> param_names;

    void setCumsum(){
        this -> cumsum = std::make_shared<Cumsum>();
    }

    double costFunction(int start, int end){
        double lSum = this -> cumsum -> getLinearSum(start, end);
        double N = end - start + 1;
        return - pow(lSum, 2)/N;
    }

    void calcParams(int start, int mid, int end){
        this -> before_mean.push_back(this -> cumsum -> getMean(start, mid));
        this -> after_mean.push_back(this -> cumsum -> getMean(mid + 1, end));
    }

    std::vector<std::vector<double>> retParams(){
        std::vector<std::vector<double>> params = {};
        params.push_back(this -> before_mean);
        params.push_back(this -> after_mean);
        return params;
    }

    std::vector<std::string> getParamNames(){
        return mean_norm::param_names;
    }
)


DISTRIBUTION(var_norm,
    std::vector<double> after_var;
    std::vector<double> before_var;
    static std::vector<std::string> param_names;

    double costFunction(int start, int end){
        double lSum = this -> cumsum -> getLinearSum(start, end);
        double sSum =  this -> cumsum -> getQuadraticSum(start, end);
        int N = end - start + 1;
        double mean = this -> cumsum -> getTotalMean(); // Fixed mean
        double varN = (sSum - 2 * mean * lSum + N * pow(mean, 2)); // Variance of segment.
        if(varN <= 0) return INFINITY;
        return N * (log(2*M_PI) + log(varN/N) + 1);
    }

    void calcParams(int start, int mid, int end){
        double varLeft = this -> cumsum -> getVarianceN(start, mid, true);
        double varRight = this -> cumsum -> getVarianceN(mid + 1, end, true);
        this -> before_var.push_back(sqrt(varLeft / (mid - start + 1)));
        this -> after_var.push_back(sqrt(varRight / (end - mid + 1)));
    }

    std::vector<std::vector<double>> retParams(){
        std::vector<std::vector<double>> params;
        params.push_back(before_var);
        params.push_back(after_var);
        return params;
    }

    std::vector<std::string> getParamNames(){
        return var_norm::param_names;
    }

)

DISTRIBUTION(meanvar_norm,
    std::vector<double> before_mean;
    std::vector<double> after_mean;
    std::vector<double> before_var;
    std::vector<double> after_var;
    static std::vector<std::string> param_names;

    double costFunction(int start, int end){
        double lSum =  this -> cumsum -> getLinearSum(start, end);
        double sSum =  this -> cumsum -> getQuadraticSum(start, end);
        int N = end - start + 1;
        double var = (sSum - (lSum*lSum/N))/N;
        if(var <= 0) return INFINITY;
        return N*(log(var) + log(2*M_PI) + 1);
    }

    void calcParams(int start, int mid, int end){
        double varLeft = this -> cumsum -> getVarianceN(start, mid, false);
        this -> before_var.push_back(sqrt(varLeft / (mid - start + 1)));

        double varRight = this -> cumsum -> getVarianceN(mid + 1, end, false);
        this -> after_var.push_back(sqrt(varRight / (end - mid + 1)));

        double meanLeft = this -> cumsum -> getMean(start, mid);
        this -> before_mean.push_back(meanLeft);

        double meanRight = this -> cumsum -> getMean(mid + 1, end);
        this -> after_mean.push_back(meanRight);
    }

    std::vector<std::vector<double>> retParams(){
        std::vector<std::vector<double>> params;
        params.push_back(this -> before_mean);
        params.push_back(this -> after_mean);
        params.push_back(this -> before_var);
        params.push_back(this -> after_var);
        return params;
    }

    std::vector<std::string> getParamNames(){
        return meanvar_norm::param_names;
    }
)


DISTRIBUTION(Poisson,
    double costFunction(int start, int end){
        return 5;
    }

    std::vector<std::vector<double>>  retParams(){
        std::vector<std::vector<double>> params;
        return params;
    }
)


DISTRIBUTION(Negbin,
    double costFunction(int start, int end){
        return 5;
    }

            std::vector<std::vector<double>>  retParams(){
                std::vector<std::vector<double>> params;
                return params;
            }
)


DISTRIBUTION(Exponential,
    double costFunction(int start, int end){
        return 5;
    }

            std::vector<std::vector<double>>  retParams(){
                std::vector<std::vector<double>> params;
                return params;
            }
)