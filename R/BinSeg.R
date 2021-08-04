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


setGeneric("algo", function(object) standardGeneric("algo"), signature="object")
setGeneric("dist", function(object) standardGeneric("dist"), signature="object")
setGeneric("cpts", function(object, ...) standardGeneric("cpts"), signature="object")
setGeneric("coef", function(object,  ...) standardGeneric("coef"), signature="object")
setGeneric("plot", function(object, ...) standardGeneric("plot"), signature="object")
setGeneric("plotDiagnostic", function(object, ...) standardGeneric("plotDiagnostic"), signature="object")
setGeneric("show", function(object) standardGeneric("show"), signature="object")
setGeneric("logLik", function(object, ...) standardGeneric("logLik"), signature="object")
setGeneric("resid", function(object, ...) standardGeneric("resid"), signature="object")

#' @describeIn BinSeg Obtain the algorithm used in the analysis.
setMethod("algo", "BinSeg", function(object) object@algorithm)


setMethod("dist", "BinSeg", function(object) object@distribution)

setMethod("cpts", "BinSeg", function(object, ncpts=seq_len(nrow(object@models_summary))){
  validateSegments(object, ncpts)
  cpts <- object@models_summary[, "cpts"][ncpts]
  return(cpts)
})

setMethod("coef", "BinSeg", function(object, segments=seq_len(nrow(object@models_summary))){
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

setMethod("logLik", "BinSeg", function(object, ncpts= seq_len(nrow(object@models_summary))){
  validateSegments(object, ncpts)
  cpts <- object@models_summary[, "cost"][ncpts]
  return(cpts)
})

setMethod("show", "BinSeg", function(object){
  object@models_summary
})

setMethod("plot", "BinSeg", function(object, ncpts=seq_len(nrow(object@models_summary)),
                                     y_axis=seq_along(object@data),
                                     title=paste("BinSeg changepoint analysis")){
  if(length(y_axis) != length(seq_along(object@data))){
    stop("The provided y_index vector must have the length as the data vector")
  }
  validateSegments(object, ncpts)
  coefs <- coef(object, ncpts)
  plot <- ggplot() +
    geom_line(data=data.frame(index = y_axis, val = object@data), # First graph the line
              mapping=aes(x=index , y=val), color="#636363") +
    geom_vline(data=coefs[start > 1],
               mapping=aes(xintercept=start + y_axis[1] - 1),
               color="#56B4E9", size=0.9) +
    facet_grid(segments ~ .) +
    theme_bw() +
    ggtitle(title, subtitle=paste("Algorithm:", object@algorithm, ",  Distribution:", object@distribution )) +
    theme(plot.title=element_text(face="bold",margin=margin(t=10,b=5),size=13),
          plot.subtitle=element_text(margin=margin(t=0,b=5)))
  return(plot)
})

setMethod("plotDiagnostic", "BinSeg", function(object, ncpts= seq_len(nrow(object@models_summary))){
  validateSegments(object, ncpts)
  plot <- ggplot() +
    geom_line(data=data.frame(cpts=object@models_summary[,cpts_index], cost=object@models_summary[,cost]),
              mapping=aes(x=cpts , y=cost), color="#636363") +
    ggtitle("Diagnostic plot: Overall cost per changepoint model",
            subtitle=paste("Algorithm:", object@algorithm, ",  Distribution:", object@distribution ))
  return(plot)
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

setMethod("resid", "BinSeg", function(object){
  coefs <- coef(object, nrow(object@models_summary))
  means <- coefs[, mean(object@data[start:end]), by=start]$V1
  vars <- coefs[, var(object@data[start:end]), by=start]$V1
  coefs <- cbind(coefs, means, vars)
  ans <- numeric()
  for(i in seq_len(nrow(coefs))){
    seg <- (object@data[coefs[["start"]][i]:coefs[["end"]][i]] - coefs[["means"]][i])  / coefs[["vars"]][i]
    ans <- c(ans,seg)
  }
  return(ans)
})