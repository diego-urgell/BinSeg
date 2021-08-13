
#include <Rcpp.h>
#include <R.h>
#include "Distributions.cpp"

// The initialization of the static variables was originally planned to be inline.
// See https://github.com/diego-urgell/BinSeg/releases/tag/std_rcpp17 for more information about this.
// This solution is temporary, and will be changed as soon as the external bug is fixed.

std::vector<std::string> mean_norm::param_names = {"before_mean", "after_mean"};
std::vector<std::string> var_norm::param_names = {"before_var", "after_var"};
std::vector<std::string> meanvar_norm::param_names = {"before_mean", "after_mean", " before_var", "after_var"};
std::vector<std::string> negbin::param_names = {"before_prob", "after_prob"};
std::vector<std::string> poisson::param_names = {"before_rate", "after_rate"};
std::vector<std::string> exponential::param_names = {"before_rate", "after_rate"};

std::string mean_norm::factoryName = "mean_norm";
std::string var_norm::factoryName = "var_norm";
std::string meanvar_norm::factoryName = "meanvar_norm";
std::string negbin::factoryName = "negbin";
std::string poisson::factoryName = "poisson";
std::string exponential::factoryName = "exponential";

std::string mean_norm::description = "Normal distribution with change in Mean and constant Variance";
std::string var_norm::description = "Normal Distribution with change in Variance and constant Mean";
std::string meanvar_norm::description = "Normal distribution with change in both mean and variance";
std::string negbin::description = "Negative Binomial distribution with change in Probability of Success";
std::string poisson::description = "Poisson distribution with change in Rate";
std::string exponential::description = "Exponential distribution with change in Rate";

std::vector<std::string> BS::param_names = {"cpts_index", "cpts", "invalidates_index", "invalidates_after", "cost"};

std::string BS::factoryName = "BS";

std::string BS::description = "Regular Binary Segmentation";

template<>
std::map<std::string, std::shared_ptr<Distribution>(*)()> GenericFactory<Distribution>::regSpecs =
        std::map<std::string, std::shared_ptr<Distribution>(*)()>();

template<>
std::map<std::string, std::shared_ptr<Algorithm>(*)()> GenericFactory<Algorithm>::regSpecs =
        std::map<std::string, std::shared_ptr<Algorithm>(*)()>();

template<>
std::map<std::string, std::string> GenericFactory<Algorithm>::regDescs = std::map<std::string, std::string>();

template<>
std::map<std::string, std::string> GenericFactory<Distribution>::regDescs = std::map<std::string, std::string>();

template<>
bool Registration<mean_norm, Distribution, DistributionFactory>::is_registered =
        DistributionFactory::Register(mean_norm::factoryName, mean_norm::description, mean_norm::createMethod);
template<>
bool Registration<var_norm, Distribution, DistributionFactory>::is_registered =
        DistributionFactory::Register(var_norm::factoryName, var_norm::description, var_norm::createMethod);
template<>
bool Registration<meanvar_norm, Distribution, DistributionFactory>::is_registered =
        DistributionFactory::Register(meanvar_norm::factoryName, meanvar_norm::description, meanvar_norm::createMethod);
template<>
bool Registration<negbin, Distribution, DistributionFactory>::is_registered =
        DistributionFactory::Register(negbin::factoryName, negbin::description, negbin::createMethod);
template<>
bool Registration<poisson, Distribution, DistributionFactory>::is_registered =
        DistributionFactory::Register(poisson::factoryName, poisson::description, poisson::createMethod);
template<>
bool Registration<exponential, Distribution, DistributionFactory>::is_registered =
        DistributionFactory::Register(exponential::factoryName, exponential::description, exponential::createMethod);

template<>
bool Registration<BS, Algorithm, AlgorithmFactory>::is_registered =
        AlgorithmFactory::Register(BS::factoryName, BS::description, BS::createMethod);


// [[Rcpp::export]]
Rcpp::NumericMatrix rcpp_binseg(Rcpp::NumericVector data, Rcpp::String algorithm, Rcpp::String distribution, int numCpts, int minSegLen){

    std::shared_ptr<Distribution> dist = DistributionFactory::Create(distribution);
    std::shared_ptr<Algorithm> algo = AlgorithmFactory::Create(algorithm);

    Rcpp::NumericMatrix params_mat = Rcpp::NumericMatrix(numCpts + 1, dist -> getParamCount() + 5);

    dist -> setCumsum();
    algo -> init(&data[0], data.size(), numCpts, dist, minSegLen, &params_mat[0]);
    algo -> binseg();

    Rcpp::colnames(params_mat) = Rcpp::wrap(algo -> getParamNames());

    return params_mat;
}


// [[Rcpp::export]]
Rcpp::CharacterMatrix distributions_info(){
    Rcpp::CharacterMatrix infoDist(DistributionFactory::regSpecs.size(), 2);
    int counter = 0;
    for (auto it = DistributionFactory::regSpecs.begin(); it != DistributionFactory::regSpecs.end(); it++){
        infoDist(counter, 0) = it -> first;
        infoDist(counter, 1) = DistributionFactory::regDescs[it -> first];
        counter++;
    }
    Rcpp::CharacterVector names = {"distribution", "description"};
    Rcpp::colnames(infoDist) = names;
    return infoDist;
}

// [[Rcpp::export]]
Rcpp::CharacterMatrix algorithms_info(){
    Rcpp::CharacterMatrix infoAlgo(AlgorithmFactory::regSpecs.size(), 2);
    int counter = 0;
    std::vector<std::string> namesAlgo =  std::vector<std::string>();
    for (auto it = AlgorithmFactory::regSpecs.begin(); it != AlgorithmFactory::regSpecs.end(); it++){
        infoAlgo(counter, 0) = it -> first;
        infoAlgo(counter, 1) = AlgorithmFactory::regDescs[it -> first];
        counter++;
    }
    Rcpp::CharacterVector names = {"algorithm", "description"};
    Rcpp::colnames(infoAlgo) = names;
    return infoAlgo;
}

