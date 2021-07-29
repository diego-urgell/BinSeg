# Title     : Class Structure
# Objective : Check that the C++ code structure is working appropriately.
# Created by: diego.urgell
# Created on: 16/06/21

library(methods)

setClass("BinSeg",
         slots=c(
           data="numeric",
           summary="matrix",
           algorithm="character",
           distribution="character",
           min_seg_len="numeric"
         ),
         prototype=list(
           data=NA_real_,
           summary=matrix(),
           algorithm=NA_character_,
           distribution=NA_character_,
           min_seg_len=NA_integer_
         )
)

setValidity("BinSeg", function(object){

})

setGeneric("algo", function(object) standardGeneric("algo"), signature="object")
setGeneric("dist", function(object) standardGeneric("dist"), signature="object")
setGeneric("cpts", function(object, ncpts) standardGeneric("cpts"), signature=c("object", "ncpts"))
setGeneric("coef", function(object, ncpts) standardGeneric("coef"), signature=c("object", "ncpts"))
setGeneric("show", function(object) standardGeneric("show"), signature="object")
setGeneric("logLik", function(object, ncpts) standardGeneric("logLik"), signature=c("object", "ncpts"))

setMethod("algo", "BinSeg", function(object) object@algorithm)

setMethod("dist", "BinSeg", function(object) object@distribution)

setMethod("cpts", c("BinSeg", "numeric"), function(object, ncpts=1:nrow(object@summary)){
  validateSegments(ncpts)
  cpts <- object@summary[, "cpts"][ncpts]
  return(cpts)
})

setMethod("coef", c("BinSeg", "numeric"), function(object, ncpts=1:nrow(object@summary)){
  object@summary
})

setMethod("logLik", c("BinSeg", "numeric"), function(object, ncpts=1:nrow(object@summary)){
  validateSegments(ncpts)
  cpts <- object@summary[, "cost"][ncpts]
  return(cpts)
})

setMethod("show", "BinSeg", function(object){
  object@summary
})

validateSegments <- function(segments){
  max_index <- nrow(object@summary)
  if(!(
    is.integer(segments) &&
      0<length(segments) &&
      all(is.finite(segments) & 0<segments & segments <= max_index)
  )){
    stop(
      "segments must be a vector of unique integers between 1 and ",
      max_index)
  }
}