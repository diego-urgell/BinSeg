//
// Created by Diego Urgell on 10/06/21.
//

#include <Rcpp.h>
#include <R.h>
#include "Distributions.cpp"

// [[Rcpp::export]]
Rcpp::List binseg(Rcpp::NumericVector data, Rcpp::String algorithm, Rcpp::String distribution, int numCpts, int minSegLen = 1){

//    std::vector<std::string> namesDist =  std::vector<std::string>();
//    for (auto it = DistributionFactory::regSpecs.begin(); it != DistributionFactory::regSpecs.end(); it++){
//        namesDist.push_back(it -> first);
//    }
//
//    std::vector<std::string> namesAlgo =  std::vector<std::string>();
//    for (auto it = AlgorithmFactory::regSpecs.begin(); it != AlgorithmFactory::regSpecs.end(); it++){
//        namesAlgo.push_back(it -> first);
//    }

    std::shared_ptr<Distribution> dist = DistributionFactory::Create(distribution);
    std::shared_ptr<Algorithm> algo = AlgorithmFactory::Create(algorithm);

    dist -> setCumsum();
    algo -> init(&data[0], data.size(), numCpts, dist, minSegLen);
    algo -> binseg();

    std::vector<std::vector<double>> cpts_vec = algo -> getParams();
    std::vector<std::vector<double>> params_vec = dist -> retParams();
    cpts_vec.insert(cpts_vec.end(), params_vec.begin(), params_vec.end());

    int rows = cpts_vec[0].size(), cols = cpts_vec.size();
    Rcpp::NumericMatrix params_mat = Rcpp::NumericMatrix(rows, cols);

    for(int i = 0; i < cols; i++){
        Rcpp::NumericVector tmp = Rcpp::wrap(cpts_vec[i]);
        params_mat.column(i) = tmp;
    }

    return Rcpp::List::create(
            Rcpp::Named("params", params_mat)
            );
}