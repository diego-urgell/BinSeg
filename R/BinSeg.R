# Title     : Class Structure
# Objective : Check that the C++ code structure is working appropriately.
# Created by: diego.urgell
# Created on: 16/06/21


#' @title An S4 class that represents a set of changepoint models.
#'
#' @slot data A numeric vector with the data used to perform the changepoint analysis.
#' @slot models_summary A data.table with the summary of the segmentation models. It is only intended for internal usage.
#' It is recommended to use the other functions to interact with the changepoint model and obtain parameter estimations.
#' @slot algorithm The algorithm string selected for the changepoint analysis.
#' @slot distribution The distribution string selected for the changepoint analysis.
#' @slot min_seg_len The value selected as the minimum segment length (default is 1).
#' @slot param_names The parameters that will be estimated by the changepoint model according to the selected distribution.
#'
#' @section Warning:
#' You should not create BinSeg objects by hand. You must provide the data to the BinSegModel function, which
#' will compute the changepoint model by using the Rcpp interface and then fix the output to create a BinSeg object and
#' return it.
#'
#' @seealso BinSegModel for computing the changepoint model and obtaining a BinSeg object.
#'
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
setGeneric("logLik", function(object, ...) standardGeneric("logLik"), signature="object")
setGeneric("resid", function(object, ...) standardGeneric("resid"), signature="object")



#' Obtain the algorithm used in the analysis.
#'
#' @param object A valid BinSeg object.
#' @return A string with the algorithm used.
setMethod("algo", "BinSeg", function(object) object@algorithm)



#' Obtain the distribution used in the analysis.
#'
#' @param object A valid BinSeg object
#' @return A string with the distribution used.
setMethod("dist", "BinSeg", function(object) object@distribution)



#' Obtain the changepoints estimated by the analysis.
#'
#' @param object A valid BinSeg object.
#' @param ncpts The number of changepoints to return (from 1 up to the number of changepoints indicated in BinSegModel).
#'
#' @section Details:
#' The changepoints are not sorted. Instead, they are arranged according to the decrease in cost. The first changepoint
#' will always be the last data point. From there, the next changepoint will be the one that decreases the most the overall
#' cost of the model, if there was only one changepoint, and so on.
#'
#' @return A numeric vector
setMethod("cpts", "BinSeg", function(object, ncpts=seq_len(nrow(object@models_summary))){
  validateSegments(object, ncpts)
  cpts <- unlist(object@models_summary[, "cpts"][ncpts], use.names=FALSE)
  return(cpts)
})



#' Obtain segment data for a particular number of changepoints.
#'
#' @description This function allows to obtain segment start, end, and parameter estimation (mean, etc. depending on the
#' selected distribution) for the selected number of segments. Can compute segment data for several models at the same time.
#' Note that the models_summary produced by rcpp_binseg is used here in order to comopute several models without doing the
#' changepoint analysis again.
#'
#' @param object A valid BinSeg object
#' @param segments The number of segments to use. Must be a numeric value. If you provide only one segment, it must be
#' accompanied by L (eg. 1L). Otherwise, if you want information about several models (ie. several number of changepoints
#' / segments), provide a vector.
#' @returns A data.table with the following fixed columns:
#' #' \describe{
#'      \item{segments}{This identifies a specific model by the number of segments. For the model with five segments,
#' each of the five rows will have a value of 5 in this column.}
#'      \item{start}{The starting index of a segment relative to the input data vector number of data points. It is
#' unique for a partiuclar model (i.e. no two segments can start on the same index}
#'      \item{end}{The ending index of a segment}
#' }
#' Additionally, columns for each estimated parameter are added. However, this depends on the selected distribution. For
#' example, if the distribution is \code{meanvar_norm}, then two columns will be added, one for segment mean and another
#' one for segment variance.
#'
#' @section Details:
#' Depending on wheter you want information about a single model or several models, you can provide different values to
#' the segments parameter:
#' \describe{
#'      \item{Atomic value:}{ This means that only the model with the specified number of segments will be computed.
#' Therefore, all the values in the segments column will be the same.}
#'      \item{Numeric vector:}{In this case, several models will be computed at the same time. The indicated models will
#' be differentiated by their segments value.}
#' }
#'
#' @seealso rcpp_binseg for the function that creates the models_summary matrix used in this function.
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


#' btain the overall costs of the computed models, from 1 up to the selected number of changepoints.
#'
#' This function returns the overall cost for each one of the models. When you perform a BinSegModel, the models up to the
#' sepcified number of changepoints are computed. This functions returns the cost of each one of them. The first value is
#' the cost of the model without segmentation (remember the first changepoint is the last datapoint). Then, it tells the
#' overall cost with each addition of a segment.
#'
#' @param object A valid BinSeg object.
#' @param ncpts The number of changepoints to return (from 1 up to the number of changepoints indicated in BinSegModel).
#'
#' @return A numeric matrix with the overall cost at each number of changepoints
setMethod("logLik", "BinSeg", function(object, ncpts= seq_len(nrow(object@models_summary))){
  validateSegments(object, ncpts)
  cpts <- unlist(object@models_summary[, "cost"][ncpts], use.names=FALSE)
  return(cpts)
})


#' Plot the data with segments
#'
#' This method provides a convenient way to visualize changepoint models. The changepoints are drawn as vertical line on
#' top of the input data. Furthermore, several models (different number of changepoints) can be plotted at once.
#'
#' @param object A valid BinSeg object
#' @param ncpts Numeric vector (might be atomic) specifying the different models to be plotted as the number of changepoints.
#' @param y_axis A numeric vector to be used for the y axis of the graph.
#' @param title The title of the graph
#'
#' @return A ggplot graph with the plot of the specified segmentation models
#'
#' @section Details:
#' This method allows to visualize several changepoint models at the same time. Each one of them is separated by using
#' a face grid. If you input only one number in ncpts (e.g. 5L), then only that segment will be graphed without facet grid.
#' When you pass a vector with several values (e.g. 1:3), then the models with those number of changepoints will be graphed.
#' Each of them will be graphed on a separate grid space. Rearding the y axis, the default setting is to use the indexes
#' of the input data vector (starting from 1 up to the length of the vector). However, if you have a y axis you can
#' provide it on the y_axis parameter. Beware that it must be of the same length as the input data vector.
#'
#' @seealso plotDiagnostic for a diagnostic plot that graphs the costs.
#'
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


#' Plot a diagnostic of the models
#'
#' This method creates a graph of the overall cost at each changepoint model up to the selected number of changepoints.
#' It allows to determine how many changepoints to consider and to visualize the cost decrease that each new segment brings.
#'
#' @param object A valid BinSeg object
#' @param ncpts The number of changepoints to consider (Default is whole model)
#'
#' @return A ggplot with the graph of the costs.
#'
#' @seealso plot For a graph of the changepoints on top of the data.
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


#' Obtain the residuals of the model
#'
#' This method allows to compute the segment residuals to later on validate the changepoint model. I has a different
#' implementation according to the distribution, but in every case it removes the distribution assumption.
#'
#' @param object A valid BinSeg object
#' @return A numeric vector with the model's residuals. It has the same length as the input data vector.
setMethod("resid", "BinSeg", function(object){
  coefs <- coef(object, nrow(object@models_summary))
  # check if mean is on the data.table
  means <- coefs[, mean(object@data[start:end]), by=start]$V1 #Dont recalculate since it is dsitribution specific.
  vars <- coefs[, var(object@data[start:end]), by=start]$V1
  coefs <- cbind(coefs, means, vars)
  ans <- numeric()
  for(i in seq_len(nrow(coefs))){ #In poisson both of them are rate.
    seg <- (object@data[coefs[["start"]][i]:coefs[["end"]][i]] - coefs[["means"]][i])  / sqrt(coefs[["vars"]][i]) # sd instead of var
    ans <- c(ans,seg)
  }
  return(ans)
})


