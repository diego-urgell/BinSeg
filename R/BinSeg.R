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
           distribution="character"
         ),
         prototype=list(
           data=NA_real_,
           summary=matrix(),
           algorithm=NA_character_,
           distribution=NA_character_
         )
)

setValidity("BinSeg", function(object){
  TRUE
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
  cpts <- object@summary[, "cpts"][ncpts]
  cpts
})

setMethod("coef", c("BinSeg", "numeric"), function(object, ncpts=1:nrow(object@summary)){
  object@summary
})

setMethod("logLik", c("BinSeg", "numeric"), function(object, ncpts=1:nrow(object@summary)){
  cpts <- object@summary[, "cost"][ncpts]
  cpts
})

setMethod("show", "BinSeg", function(object){
  object@summary
})
