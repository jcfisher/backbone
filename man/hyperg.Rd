% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hyperg.R
\name{hyperg}
\alias{hyperg}
\title{Compute hypergeometric backbone}
\usage{
hyperg(B)
}
\arguments{
\item{B}{Matrix: Bipartite network}
}
\value{
list(positive, negative).
positive gives matrix of probability of ties above the observed value.
negative gives matrix of probability of ties below the observed value.
}
\description{
`hyperg` computes the probability of observing
    a higher or lower edge weight using the hypergeometric distribution.
    Once computed, use \code{\link{backbone.extract}} to return
    the backbone matrix for a given alpha value.
}
\examples{
hypergeometric_bb <- hyperg(davis)
}
\references{
\href{https://doi.org/10.1007/s13278-013-0107-y}{Neal, Zachary. 2013. “Identifying Statistically Significant Edges in One-Mode Projections.” Social Network Analysis and Mining 3 (4). Springer: 915–24. DOI:10.1007/s13278-013-0107-y.}
}
