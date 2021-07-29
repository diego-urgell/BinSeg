# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 27/07/21

BinSeg <- function(data, algorithm, distribution, numCpts=1, minSegLen=1){

  if(!is.numeric(data)){
    stop("Only numeric data allowed")
  }

  if(anyNA(data)){
    stop("Missing value: NA is not allowed in the data as changepoint methods assume regularly spaced data.")
  }

  if(length(data) < 1){
    stop("At least one datapoint is needed")
  }

  if(! algorithm %in% algorithms_info()[,"algorithm"]){
    stop("The selected algorithm is not currently implemented. Use BinSegInfo() to check the available algorithms")
  }

  if(! distribution %in% distributions_info()[,"distributions"]){
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
    stop(paste("Too many segments. Given the length of data vector and the distribution,
     the maximum number of segments is ", max_segments))
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

  if (var(data) == 0){
    stop("Not possible to compute a changepoint model if all the data points are the same.")
  }

  summary <- binseg(data, algorithm, distribution, numCpts, minSegLen)
  BinSegObj <- new("BinSeg", data=data, summary=summary, algorithm=algorithm, distribution=distribution)

  if (nrow(BinSegObj@models_summary) < numCpts){
    warning("The amount of changepoints found is smaller than the expected number. It was not possible to further
    partition the data since the remaining segments all have zero variance.")
  }

  return(BinSegObj)
}

BinSegInfo <- function(){
  info <- list("algorithms"=algorithms_info(), "distributions"=distributions_info())
  return(info)
}