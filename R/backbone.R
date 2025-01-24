#' backbone: Extracts the Backbone from Weighted Graphs
#'
#' @description Provides methods for extracting from a weighted graph
#'     a binary or signed backbone that retains only the significant edges.
#'     The user may input a weighted graph, or a bipartite graph
#'     from which a weighted graph is first constructed via projection.
#'     Backbone extraction methods include the stochastic degree sequence model (Neal, Z. P. (2014). <doi:10.1016/j.socnet.2014.06.001>),
#'     hypergeometric model (Neal, Z. (2013). <doi:10.1007/s13278-013-0107-y>),
#'     the fixed degree sequence model (Zweig, K. A., and Kaufmann, M. (2011). <doi:10.1007/s13278-011-0021-0>),
#'     as well as a universal threshold method.
#'
#' @details Some features of the package are:
#' \itemize{
#' \item '\code{\link{universal}}': returns a unipartite backbone matrix in which
#' values are set to 1 if above the given upper parameter threshold,
#' and set to -1 if below the given lower parameter threshold, and are 0 otherwise.
#' \item '\code{\link{sdsm}}': computes the proportion of generated edges above or below the observed value using the stochastic degree sequence model. Once computed, use \code{\link{backbone.extract}} to return the backbone matrix for a given alpha value.
#' \item '\code{\link{fdsm}}': computes the proportion of generated edges above or below the observed value using the fixed degree sequence model. Once computed, use \code{\link{backbone.extract}} to return the backbone matrix for a given alpha value.
#' \item '\code{\link{hyperg}}': returns a binary or signed adjacency matrix
#'  containing the backbone that retains only the significant edges.
#' \item '\code{\link{backbone.extract}}': returns a positive or signed adjacency matrix
#'  containing the backbone: only the significant edges.
#' }
#'
#' @details For additional documentation and background on the package functions, see \code{browseVignettes("backbone")}.
#' @docType package
#' @name backbone
NULL
