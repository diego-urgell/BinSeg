# Title     : Class Structure
# Objective : Check that the C++ code structure is working appropriately.
# Created by: diego.urgell
# Created on: 16/06/21

library(methods)

setClass("BinSeg",
         slots=c(
           data="numeric",
           models_summary="data.table",
           algorithm="character",
           distribution="character",
           min_seg_len="numeric",
           param_names="character"
         ),
         prototype=list(
           data=NA_real_,
           models_summary=data.table(),
           algorithm=NA_character_,
           distribution=NA_character_,
           min_seg_len=NA_integer_,
           param_names=NA_character_
         )
)

setValidity("BinSeg", function(object){

})

setGeneric("algo", function(object) standardGeneric("algo"), signature="object")
setGeneric("dist", function(object) standardGeneric("dist"), signature="object")
setGeneric("cpts", function(object, ncpts) standardGeneric("cpts"), signature=c("object", "ncpts"))
setGeneric("coef", function(object,  ...) standardGeneric("coef"), signature="object")
setGeneric("plot", function(object, ncpts) standardGeneric("plot"), signature=c("object", "ncpts"))
setGeneric("plotCost", function(object, ncpts) standardGeneric("plotCost"), signature=c("object", "ncpts"))
setGeneric("show", function(object) standardGeneric("show"), signature="object")
setGeneric("logLik", function(object, ncpts) standardGeneric("logLik"), signature=c("object", "ncpts"))
# resid checks for residuals

setMethod("algo", "BinSeg", function(object) object@algorithm)

setMethod("dist", "BinSeg", function(object) object@distribution)

setMethod("cpts", c("BinSeg", "numeric"), function(object, ncpts=1:nrow(object@models_summary)){
  validateSegments(ncpts)
  cpts <- object@models_summary[, "cpts"][ncpts]
  return(cpts)
})

setMethod("coef", "BinSeg", function(object, segments=1:nrow(object@models_summary)){
  validateSegments(object, segments)
  model <- data.table(segments)[, {
     i <- 1:segments
     curr_segs <- object@models_summary[i]
     ord <- order(curr_segs$cpts)
     ans <- curr_segs[ord, data.table(
       start=c(1L, cpts[-.N]+1L),
       end=cpts
     )]
     for(j in seq_along(object@param_names)){
       jj <- 6 + (j - 1)*2
       ans <- cbind(ans, build_param(jj, jj+1, curr_segs, object@param_names[j]))
     }
     ans
  }, by=segments]

  return(model)
})


build_param <- function(before_param, after_param, summary_dt, col_name){
  param_full <- unlist(summary_dt[, c(before_param, after_param), with=FALSE, drop=TRUE], use.names=FALSE)
  param_full[
    summary_dt[, .N*invalidates_after+invalidates_index]
  ] <- NA
  ord <- order(summary_dt$cpts)
  param_mat <- matrix(param_full, 2, byrow=TRUE)[, ord]
  param <- summary_dt[ord, data.table(param_mat[!is.na(param_mat)])]
  names(param) <- col_name
  return(param)
}


setMethod("logLik", c("BinSeg", "numeric"), function(object, ncpts=1:nrow(object@models_summary)){
  validateSegments(ncpts)
  cpts <- object@models_summary[, "cost"][ncpts]
  return(cpts)
})

setMethod("show", "BinSeg", function(object){
  object@models_summary
})

validateSegments <- function(object, segments){
  max_index <- nrow(object@models_summary)
  if(!(
    is.integer(segments) &&
      0<length(segments) &&
      all(is.finite(segments) & 0<segments & segments <= max_index)
  )){
    stop(
      "Segments must be a vector of unique integers between 1 and ",
      max_index)
  }
}