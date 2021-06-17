//
// Created by Diego Urgell on 10/06/21.
//

#include <Rcpp.h>
#include <R.h>
#include "Distributions.cpp"


// [[Rcpp::export]]
Rcpp::NumericVector binseg(Rcpp::NumericVector data, Rcpp::String algorithm, Rcpp::String distribution){
    std::vector<std::string> namesDist =  std::vector<std::string>();
    for (auto it = DistributionFactory::regSpecs.begin(); it != DistributionFactory::regSpecs.end(); it++){
        namesDist.push_back(it -> first);
    }

    std::vector<std::string> namesAlgo =  std::vector<std::string>();
    for (auto it = AlgorithmFactory::regSpecs.begin(); it != AlgorithmFactory::regSpecs.end(); it++){
        namesAlgo.push_back(it -> first);
    }

    std::shared_ptr<Distribution> dist = DistributionFactory::Create(distribution);
    std::shared_ptr<Algorithm> algo = AlgorithmFactory::Create(algorithm);

    dist -> setCumsum();
    algo -> init(dist);
    Rcpp::NumericVector ans(data.size());

    algo -> binseg(&data[0], data.size(), &ans[0]);
    return ans;
}