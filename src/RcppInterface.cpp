//
// Created by Diego Urgell on 10/06/21.
//

#include <Rcpp.h>
#include <R.h>
#include "Distributions.cpp"

std::vector<std::string> mean_norm::param_names = {"before_mean", "after_mean"};
std::vector<std::string> var_norm::param_names = {"before_var", "after_var"};
std::vector<std::string> meanvar_norm::param_names = {"before_mean", "after_mean", " before_var", "after_var"};
std::vector<std::string> negbin::param_names = {"before_prob", "after_prob"};

std::vector<std::string> BS::param_names = {"cpts", "invalidates_index", "invalidates_after", "cost"};


// [[Rcpp::export]]
Rcpp::NumericMatrix binseg(Rcpp::NumericVector data, Rcpp::String algorithm, Rcpp::String distribution, int numCpts, int minSegLen = 1){

    std::shared_ptr<Distribution> dist = DistributionFactory::Create(distribution);
    std::shared_ptr<Algorithm> algo = AlgorithmFactory::Create(algorithm);

    Rcpp::NumericMatrix params_mat = Rcpp::NumericMatrix(numCpts + 1, dist -> getParamCount() + 4);

    dist -> setCumsum();
    algo -> init(&data[0], data.size(), numCpts, dist, minSegLen, &params_mat[0]);
    algo -> binseg();

    Rcpp::colnames(params_mat) = Rcpp::wrap(algo -> getParamNames());

    return params_mat;
}


// [[Rcpp::export]]
Rcpp::List binseg_info(){

    std::vector<std::string> namesDist =  std::vector<std::string>();
    for (auto it = DistributionFactory::regSpecs.begin(); it != DistributionFactory::regSpecs.end(); it++){
        namesDist.push_back(it -> first);
    }

    std::vector<std::string> namesAlgo =  std::vector<std::string>();
    for (auto it = AlgorithmFactory::regSpecs.begin(); it != AlgorithmFactory::regSpecs.end(); it++){
        namesAlgo.push_back(it -> first);
    }

    Rcpp::CharacterVector namesDistR = Rcpp::wrap(namesDist);

    return Rcpp::List::create(
        Rcpp::Named("Distributions", namesDistR)
    );
}

