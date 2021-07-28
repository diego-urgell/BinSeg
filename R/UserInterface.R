# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 27/07/21

BinSeg <- function(data, algorithm, distribution, numCpts=1, minSegLen=1){
  summary <- binseg(data, algorithm, distribution, numCpts, minSegLen)
  BinSegObj <- new("BinSeg", data=data, summary=summary, algorithm=algorithm, distribution=distribution)
  BinSegObj
}