# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 27/07/21

#' @include BinSeg.R
#' @title Compute Changepoint Model
#'
#' @description This is the main function of the BinSeg package. It performs changepoint analysis on the provided data using the
#' selected algorithm and distribution. Computes the optimal changepoints and estimates the parameters in each segment.
#' Note that it is possible to view segmentation models from 1 up to the selected number of changepoints, by using
#' the methods provided by the BinSeg Class.
#'
#' @param data A numeric vector containing the input data. Must have at least length 1.
#' @param algorithm A string with the algorithm to be used. Currently only "BS" (Binary Segmentation) is implemented.
#' @param distribution A string with the distribution to be used. Use BinSegInfo to check the available
#' distributions and their description.
#' @param numCpts Integer determining the number of changepoints to be computed. Must be at least one. For the norm_mean
#' distribution, as the variance is assumed to be constant, there can be up to N number of changepoints. However, for every
#' other distribution, there are at most N/2.
#' @param minSegLen Integer determining the minimum segment length. For the norm_mean distribution, the minimum segment
#' length is 1. However, for all the other ones it is 2, since each segment must have two data points to calculate variance.
#'
#' @return A BinSeg object containing the models_summary data table, as well as extra information such as the distribution,
#' algorithm, number of changepoints, and parameters.
#'
#' @examples
#' # First, get some data to analyse. In this case, it follows a normal distribution with change in mean.
#' data  <-  c(rnorm(10, 0, 10), rnorm(10, 100, 10), rnorm(10, 50, 10))
#'
#' # Call BinSegInfo in order to know the available distributions and algorithms
#' BinSegInfo()
#'
#' # Given the type of change, choose norm_mean, with the BS algorithm and 2 changepoints). Get a BinSeg object in return
#' models <- BinSegModel(data=data, algorithm="BS", distribution="mean_norm", numCpts=2)
#'
#' # In order o get parameter estimations only for the model with 2 changepoints, call the coef function
#' coef(models, 2L)
#'
#' # To plot the whole model, use plot
#' plot(models)
#'
#' #To get a diagnostic plot, use plotDiagnostic
#' plotDiagnostic(models)
#'
#'
#' @section Details:
#' This is the only function that must be called to perform a new changepoint analysis with the BinSeg package. Internally,
#' it first makes several validations to the input parameters. After this, it calls the binseg function, which connects
#' with C++ code using Rcpp. Later on it makes some modifications to the returned matrix (which will be used as models_summary
#' data table) and creates a new BinSeg object which is returned. Note that in order to use any of the methods from the
#' BinSeg class you must use this function instead of directly calling the binseg function.
#'
#' @seealso BinSegInfo to know the available algorithms and distributions, binseg to check out
#' the Rcpp function. BinSeg to check the return class sructure and available methods.
#'
BinSegModel <- function(data, algorithm, distribution, numCpts=1, minSegLen=1){

  if(!is.numeric(data)){
    stop("Only numeric data allowed")
  }

  if(anyNA(data)){
    stop("NA is not allowed")
  }

  if(length(data) < 1){
    stop("At least one datapoint is needed")
  }

  if(! algorithm %in% algorithms_info()[,"algorithm"]){
    stop("The selected algorithm is not currently implemented. Use BinSegInfo() to check the available algorithms")
  }

  if(! distribution %in% distributions_info()[,"distribution"]){
    stop("The selected distribution is not currently implemented. Use BinSegInfo() to check the available distributions")
  }

  if(!is.numeric(numCpts)){
    stop("The number of changepoints (numCpts) must be a numeric value.")
  }

  if (numCpts < 1){
    stop("Need at least one segment to perform changepoint anaylsis")
  }

  max_segments <- length(data)
  if (distribution != "mean_norm"){
    max_segments <- max_segments %/% 2
  }

  if (numCpts > max_segments){
    stop(paste("Too many segments. Given the length of data vector and the distribution, the maximum number of segments is", max_segments))
  }

  if(!is.numeric(minSegLen)){
    stop("The minimum segment length must be a numeric value")
  }
  if (distribution == "mean_norm"){
    if(minSegLen < 1){
      stop("The minumum segment length must be a least 1.")
    }
  }
  else{
    if(minSegLen < 2){
      stop("For this distribution, the minimum segment length must be at least 2 given the change in variance")
    }
  }

  if (minSegLen * numCpts > length(data)){
    stop("Given the minimum segment length and the length of the data, it is no possible to obtain the desired number of segments")
  }

  summary <- as.data.table(rcpp_binseg(data, algorithm, distribution, numCpts, minSegLen))

  summary <- summary[apply(summary, 1, function(x) !all(x==0)),] # Eliminate all zero rows

  summary[invalidates_index < 0, invalidates_index := NA,] # Set first invalidate info to NA
  summary[invalidates_after < 0, invalidates_after := NA,]

  na_inf <- function(x) is.nan(x) | is.infinite(x) # Set inf parameters to NA
  for (j in seq_len(ncol(summary))){
     set(summary,which(na_inf(summary[[j]])),j,NA)
  }

  if (distribution == "mean_norm"){
    param_names <- "mean"
    summary <- summary[, cost := cost + sum(data^2)] # Adding the missing cumsum squared
  }
  else if(distribution == "var_norm") param_names <- "variance"
  else if (distribution == "meanvar_norm") param_names <- c("mean", "variance")
  else if (distribution == "negbin") param_names <- "success_probability"
  else if (distribution == "poisson"){
    param_names <- "rate"
    summary <- summary[, cost := cost + sum(data) + sum(lgamma(data))]
  }
  else if (distribution == "exponential"){
    param_names <- "rate"
    summary <- summary[, cost := cost + length(data)]
  }

  summary <- summary[, cost := cost * 2]

  BinSegObj <- new("BinSeg", data=data, models_summary=summary, algorithm=algorithm,
                   distribution=distribution, min_seg_len=minSegLen, param_names=param_names)

  if (nrow(BinSegObj@models_summary) < numCpts){
    warning("The amount of changepoints found is smaller than the expected number. It was not possible to further
    partition the data since the remaining segments all have zero variance.")
  }

  return(BinSegObj)
}
#' @include BinSeg.R
#'
#' @title Check available algorithms and distributions
#'
#' @description This function allows to check which algorithms and distributions are implemented in the package. It provides the string
#' that must be passed as a parameter to the BinSeg method, along with a small description.
#'
#' @return A List with two slots, one for Algorithms and one for Distributions. Each one of them is a Character Matrix
#' with a column for the parameter string and another one for the description.
#'
#' @section Details:
#' This method queries directly the C++ code in order to find which distributions are currently available, as well as the
#' name that must be passed to use them. The benefit is that no R code must be modified when a new Distribution or
#' Algorithm is added. Only by adding on C++ it is possible to register it on the return matrix of this method.
#'
#' @seealso BinSegModel to perform changepoint analysis.
BinSegInfo <- function(){
  info <- list("algorithms"=algorithms_info(), "distributions"=distributions_info())
  return(info)
}



