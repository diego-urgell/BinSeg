% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BinSeg.R
\name{resid,BinSeg-method}
\alias{resid,BinSeg-method}
\alias{resid}
\title{Obtain the residuals of the model}
\usage{
\S4method{resid}{BinSeg}(object)
}
\arguments{
\item{object}{A valid BinSeg object}
}
\value{
A numeric vector with the model's residuals. It has the same length as the input data vector.
}
\description{
This method allows to compute the segment residuals to later on validate the changepoint model. I has a different
implementation according to the distribution, but in every case it removes the distribution assumption.
}
