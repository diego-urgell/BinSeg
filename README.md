<!-- badges: start -->
[![R-CMD-check](https://github.com/diego-urgell/BinSeg/workflows/R-CMD-check/badge.svg)](https://github.com/diego-urgell/BinSeg/actions)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/5093c3a6d36340539d1157b365c53bb2)](https://www.codacy.com/gh/diego-urgell/BinSeg/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=diego-urgell/BinSeg&amp;utm_campaign=Badge_Grade)
[![Codecov test coverage](https://codecov.io/gh/diego-urgell/BinSeg/branch/main/graph/badge.svg)](https://codecov.io/gh/diego-urgell/BinSeg?branch=main)
<!-- badges: end -->

# BinSeg

An R package for efficient changepoint analysis using the Binary Segmentation Algorithm, with support for several statistical distributions and types of change. 

## Table of Contents

<div align="left">
  <ul>
    <li> <a href="#background"> Background </a>  <br>
    <li> <a href="#package-usage"> Usage </a> <br>
    <li> <a href="#quality-assurance"> Quality Assurance </a> <br>
    <li> <a href="#gsoc-2021"> GSOC 2021 </a> <br>
  </ul>
</div>

## Background

When dealing with time series, sometimes the trend in a signal seems to suddenly change at a certain point. Assuming that the whole data can be modelled by a particular distribution, then the changepoint splits the dataset into two different segments, each of them with distinct distribution parameters. 

The objective of changepoint detection algorithms is to compute the best possible segmentation of a signal, and provide an estimation of the distribution parameters for each partition. A distribution specific loss function, usually the negative log-likelihood, is used to determine the optimal changepoints (Truong et al, 2020).

There are many algorithms to perform changepoint analysis. In practice, Binary Segmentation is the fastest one (Killick et al, 2012), and provides a heuristic model (i.e. is not exact). It is widely used for large datasets.

This package provides a fast and efficient implementation of Binary Segmenation, with support for several distributions. The changepoint analysis is performed in C++, and Rcpp is used to interface with R. An object-oriented design makes the package seamlessly extensible in terms of algorithms and distributions. 

The development of this project was funded by Google Summer of Code 2021. My mentors were Dr. Rebecca Killick (@rkillick) and Dr. Toby Hocking (@tdhock). Both of them provided essential guidance and support. 

## Package Usage

### Installation

First, it is necessary to install the package. Currently, the package must be installed from GitHub. It requires at least R 4.0.

```r
if(!require(remotes)) install.packages("remotes")
remotes::install_github("diego-urgell/BinSeg")
```
---

### Compute a changepoint model 

For a quick example, create a random vector using normal distribution with change in mean and variance. In this case, the changepoint locations are not visually obvious.

 ```r
set.seed(100)
data <- c(rnorm(25, 100, 50),
          rnorm(50, 65, 70),
          rnorm(30, 80, 40),
          rnorm(60, 45, 60),
          rnorm(25, 20, 80))
base::plot(data, type="l")
 ```
 
 ![base-data](https://user-images.githubusercontent.com/45611081/130337404-05904347-6e70-4157-8c03-4ea40f04fb61.png)

Then, perform a changepoint analysis by using the `BinSegModel` function.  This function will return a `BinSeg` object, which has several methods to visualize and interact with the changepoint model. The `cpts` and `logLik` methods provide the index and overall cost (`-2*logLik`) for each changepoint from 1 up to the selected `numCpts` ordered by optmality; however, the first value at both vectors considers the whole signal. 

```r
changepoint_model <- BinSegModel(data=data, algorithm="BS", distribution="meanvar_norm", numCpts=4, minSegLen=2)
BinSeg::cpts(changepoint_model)
BinSeg::logLik(changepoint_model)
```

```r
[1]  190  18 104 175  75
[1] 4210.436 4151.478 4109.260 4078.576 4058.294
```

To get more information about the available algorithms and distributions, call `BinSegInfo()`. At the moment, six distributions are supported. 

---

### Visualize the model

To visualize the model, there are two available functions. The `plot` function graphs the changepoints as vertical lines on top of the original data, for every model from 1 up to `numCpts`. It uses a facet so that each model is on a separate graph (labeled by number of segments). It is possible to indicate which models to graph by providing a vector with the desired number of segments. 

```r
BinSeg::plot(changepoint_model)
```
![Rplot01](https://user-images.githubusercontent.com/45611081/130339074-0e32af74-ded0-43a3-990f-0b4d237b0071.png)

On the other hand, `plotDiagnostic` graphs the overall cost of the model as more changepoints are consideed, starting with the whole signal and up to `numCpts`. 

```r
BinSeg::plotDiagnostic(changepoint_model)
```

![Rplot02](https://user-images.githubusercontent.com/45611081/130339089-3f30d040-4418-4acd-b745-36eb3dc36a97.png)

### Parameter information and model validation

To get information about the parameters for a particular model (or set of models) use the `coef` method. It returns a `data.table` with parameter estimation for every segment in the selected models. In the example, only the model with five segments is considered (if no argument is provided, every model is considered). 

```r
 BinSeg::coef(changepoint_model, 5L)
```

```
   segments start end      mean  variance
1:        5     1  18 102.11350  533.1086
2:        5    19  75  71.87952 5696.4282
3:        5    76 104  77.62365 1894.5617
4:        5   105 175  40.18724 1827.2455
5:        5   176 190  17.65714 6596.6811
```

To validate the model, use the `resid` function, which computes the residuals of the model considering the estimated parameters and returns a vector of the same length as the input dataset. 

## Quality Assurance

Several checks were performed to ensure that the implementation of the algorithm was correct, and that the package is portable and consistent. 

| Check | Description | Badge |
|---|---|---|
| Continuous Intgeration (CI)  | The package was checked in three platforms (Windows, Ubuntu, MacOS) with R version 4.1. Each one of the checks built the package and performed an `R CMD check --as-cran`. This ensures it meets all the CRAN requirements for submission. | GitHub Actions Build Status Badge [![R-CMD-check](https://github.com/diego-urgell/BinSeg/workflows/R-CMD-check/badge.svg)](https://github.com/diego-urgell/BinSeg/actions) |
| Code Quality | A static code analyzer was used to make sure the code follows best practices and is readable for other developers. | Codacy Code Quality Badge [![Codacy Badge](https://app.codacy.com/project/badge/Grade/5093c3a6d36340539d1157b365c53bb2)](https://www.codacy.com/gh/diego-urgell/BinSeg/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=diego-urgell/BinSeg&amp;utm_campaign=Badge_Grade) |
| Tests Coverage | The `testthat` package was used for automated tests. More than 85 tests were written, covering every functionality of the package. The tests were executed at each CI build. | Codecov Tests Coverage Badge [![Codecov test coverage](https://codecov.io/gh/diego-urgell/BinSeg/branch/main/graph/badge.svg)](https://codecov.io/gh/diego-urgell/BinSeg?branch=main) | 

## GSOC 2021

For ten weeks, during 2021 summer, I worked every weekday on this package as my Google Summer of Code project. It was a great experience, since I had never worked on an R package and then I created one from scratch. I learnt a lot of things during the development. Before this project, I had very little knowledge of statistics, but I understood more things along the way. I also got to know new patterns for object-oriented design in C++. Furthermore, I gained practical experience with software development best practices, such as planning, documenting, testing, and using CI. I also have a very clear idea of how Open Source develoment works, and I am excited to contribute to other projects. Most importantly, I experienced the development process of bigger project (compared to my past projecs), and how many challenges and obstacles appear and must be overcome to create a succesful final product. 

### Acknowledgements

I feel very grateful to my mentors Dr. Rebecca Killick and Dr. Toby Hocking. They provided very valuable feedback, suggestions, and support. I learnt a lot on our meetings. Here is an [account](https://github.com/diego-urgell/BinSeg/issues/2) of each of them. 

I am also grateful to the Google and the GSOC administrators, who make possible this amazing experience. 

### Achieved goals

-  The package succesfully implements the Binary Segmentation algorithm. Its correcteness was tested not only by using `testthat`, but also by comparing the results with the ones produced by other packages such as `changepoint` (Dr. Rebecca Killick) and `binsegRcpp` (Dr. Toby Hocking). 
-  Supports completely five types of change for the cost function (`mean_norm`, `var_norm`, `meanvar_norm`, `poisson` and `exponential`. The Negative Binomial `negbin` cost function is also implemented and tested, but it is yet to be validated against another package. 
-  Supports the input of minimum length segment constraints. For distributions in which the variance changes, it also restricts the minimum segment length to a value greater than two. 
-  An object-oriented structure was created for the C++ code. This results in very readable code, and an easily extensible package. Adding a new distribution or algorithm requires no modification to the rest of the code. A factory pattern is used to avoid confusing blocks of if statements. 
-  The `std::multiset` data structure was used to identify optimal changepoints efficiently at each iteration of the algorithm. 
-  An R class, `BinSeg`, is used to represent and store the changepoint analysis results. It provides a friendly user interface with several useful methods to graph the costs, the segmentation models, and to obtain the models residuals. 
-  A single execution of the `BinSegModel` function provides the necessary information to build changepoint models from 1 up to the selected number of changepoints. Therefore, it is not necessary to compute again the same values for any model smaller than `numCpts`. This is done using the `coef` method. 

### Challenges

During the development, several challenges were faced: 

-  The initial C++ class structure that I proposed turned out to be inefficient, so a new structure was created with the help of the mentors. The resulting code was far much better, but it required a significant amount of time and research. 
-  The implementation of the first cost function and the Binary Segmentation algorithm was very difficult because they both depended on each other. It wes difficult to identify bugs since they could be either on the `Algorithm` class or on the `Distribution`. To overcome this, I used `lldb` automated with Python scripts to find were the computations were going wrong. 
-  The first distribution implemented was `mean_norm` which does not depend on the variance of the data. Later on, when the other cost functions were added, the code did not execute succesfully. With the help of my mentors we found the problem was that the minimum segment length was not implemented yet and this resulted in computing the variance of a single data point (not defined). 
-  My implementation of the cost function for poisson and exponential distribution initially was different from the one in the `changepoint` package. After talking with my mentors, I understood how it could be optimized in C++ and then completed in R code. Splitting the cost functions by removing the constant parameters results in a reduced complexity (altough not asympotically) for some distributions. 
-  Several bugs were found when I was creating the final tests for the package. This was really positive since I made sure there were less mistakes in the code. 

### Future Development

The package is fully functional right now, and the realease for GSOC can be installed and used by anyone. The expected goals for this summer were pretty much fulfilled (with the exception of the negbin function validation), and some extra functionality was implemented. However, there are many things that can (and will) be done in the future: 

-  Finish validating the implementation of the Negative Binomial cost function. 
-  Implement other Binary Segmentation based algorithms, such as Wild Binary Segmentation and Seeded Binary Segmentation. 
-  Include support for penalty functions, so that the user does not have to provide a maximum number of changepoints. 
-  Develop cost functions for other distributions, to make the package more versatile.
-  Implement support for multivariate changepoint analysis. 
-  Complete the resid funcion so that it works also for exponential and negative binomial distributions. 

