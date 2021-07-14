//
// Created by Diego Urgell on 10/06/21.
//

#include <Rcpp.h>
#include <R.h>
#include "Distributions.cpp"

std::vector<std::string> mean_norm::param_names = {"before_mean", "after_mean"};
std::vector<std::string> var_norm::param_names = {"before_var", "after_var"};
std::vector<std::string> meanvar_norm::param_names = {"before_mean", "after_mean", " before_var", "after_var"};

std::vector<std::string> BS::param_names = {"cpts", "invalidates_index", "invalidates_after", "cost"};



// [[Rcpp::export]]
Rcpp::List binseg(Rcpp::NumericVector data, Rcpp::String algorithm, Rcpp::String distribution, int numCpts, int minSegLen = 1){

    std::shared_ptr<Distribution> dist = DistributionFactory::Create(distribution);
    std::shared_ptr<Algorithm> algo = AlgorithmFactory::Create(algorithm);

    dist -> setCumsum();
    algo -> init(&data[0], data.size(), numCpts, dist, minSegLen);
    algo -> binseg();

    std::vector<std::string> names = algo -> getParamNames();
    std::vector<std::string> param_names = dist -> getParamNames();
    names.insert(names.end(), param_names.begin(), param_names.end());

    Rcpp::CharacterVector names_vec = Rcpp::wrap(names);

    std::vector<std::vector<double>> cpts_vec = algo -> getParams();
    std::vector<std::vector<double>> params_vec = dist -> retParams();
    cpts_vec.insert(cpts_vec.end(), params_vec.begin(), params_vec.end());

    int rows = cpts_vec[0].size(), cols = cpts_vec.size();
    Rcpp::NumericMatrix params_mat = Rcpp::NumericMatrix(rows, cols);
    Rcpp::colnames(params_mat) = names_vec;

    for(int i = 0; i < cols; i++){
        Rcpp::NumericVector tmp = Rcpp::wrap(cpts_vec[i]);
        params_mat.column(i) = tmp;
    }

    return Rcpp::List::create(
            Rcpp::Named("params", params_mat)
            );
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

