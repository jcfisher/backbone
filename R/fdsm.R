#' The fixed degree sequence model (fdsm)
#'
#' `fdsm` computes the proportion of generated edges above
#'     or below the observed value using the fixed degree sequence model.
#'     Once computed, use \code{\link{backbone.extract}} to
#'     return the backbone matrix for a given alpha value.
#'
#' @param B Matrix: Bipartite adjacency matrix
#' @param trials Integer: Number of random bipartite graphs generated
#' @param sparse Boolean: If sparse matrix manipulations should be used
#' @param dyad vector length 2: two row entries i,j. Saves each value of the i-th row and j-th column in each projected B* matrix. This is useful for visualizing an example of the empirical null edge weight distribution generated by the model. These correspond to the row and column indices of a cell in the projected matrix , and can be written as their string row names or as numeric values.
#' @param progress Boolean: If \link[utils]{txtProgressBar} should be used to measure progress
#'
#' @details During each iteration, fdsm computes a new B* matrix using the Curveball algorithm. This is a random bipartite matrix with the same row and column sums as the original matrix B.
#'     If the dyad_parameter is indicated to be used in the parameters, when the B* matrix is projected, the projected value for the corresponding row and column will be saved.
#'     This allows the user to see the distribution of the edge weights for desired row and column.
#'
#' @return list(positive, negative, dyad_values).
#' positive: matrix of proportion of times each entry of the projected matrix B is above the corresponding entry in the generated projection.
#' negative: matrix of proportion of times each entry of the projected matrix B is below the corresponding entry in the generated projection.
#' dyad_values: list of edge weight for i,j in each generated projection.
#'
#' @references fixed degree sequence model: \href{https://doi.org/10.1007/s13278-011-0021-0}{Zweig, Katharina Anna, and Michael Kaufmann. 2011. “A Systematic Approach to the One-Mode Projection of Bipartite Graphs.” Social Network Analysis and Mining 1 (3): 187–218. DOI: 10.1007/s13278-011-0021-0.}
#' @references curveball algorithm: \href{https://www.nature.com/articles/ncomms5114}{Strona, Giovanni, Domenico Nappo, Francesco Boccacci, Simone Fattorini, and Jesus San-Miguel-Ayanz. 2014. “A Fast and Unbiased Procedure to Randomize Ecological Binary Matrices with Fixed Row and Column Totals.” Nature Communications 5 (June). Nature Publishing Group: 4114. DOI:10.1038/ncomms5114.}
#'
#' @export
#'
#' @examples
#' fdsm_props <- fdsm(davis, trials = 100, sparse = TRUE, dyad=c(3,6))

fdsm <- function(B,
                 trials = 1000,
                 sparse = TRUE,
                 dyad = NULL,
                 progress = FALSE){

  #Argument Checks
  if ((sparse!="TRUE") & (sparse!="FALSE")) {stop("sparse must be either TRUE or FALSE")}
  if ((trials < 1) | (trials%%1!=0)) {stop("trials must be a positive integer")}
  if (class(B) != "matrix" & !(is(B, "sparseMatrix"))) {stop("input bipartite data must be a matrix")}

  #Project to one-mode data
  if (sparse=="TRUE") {
    if (!is(B, "sparseMatrix")) {
      B <- Matrix::Matrix(B, sparse = T)
    }
    P <- Matrix::tcrossprod(B)
  } else {
    P <- tcrossprod(B)
  }

  #Create Positive and Negative Matrices to hold backbone
  Positive <- matrix(0, nrow(P), ncol(P))
  Negative <- matrix(0, nrow(P), ncol(P))

  #Dyad save
  edge_weights <- numeric(trials)
  if (length(dyad) > 0){
    if (class(dyad[1]) != "numeric"){
      vec <- match(c(dyad[1], dyad[2]), rownames(B))
    }
    else{
      vec <- dyad
    }
  }

  #Build null models
  for (i in 1:trials){

    #Algorithm credit to: Strona, G., Nappo, D., Boccacci, F., Fattorini, S., San-Miguel-Ayanz, J. (2014). A fast and unbiased procedure to randomize ecological binary matrices with fixed row and column totals. Nature Communications, 5, 4114
    #Use curveball to create an FDSM Bstar
    m <- B
    RC=dim(m) #matrix dimensions
    R=RC[1]   #number of rows
    C=RC[2]   #number of columns
    hp=list() #create a list
    for (row in 1:dim(m)[1]) {hp[[row]]=(which(m[row,]==1))}
    l_hp=length(hp)
    for (rep in 1:(5*l_hp)){
      AB=sample(1:l_hp,2)
      a=hp[[AB[1]]]
      b=hp[[AB[2]]]
      ab=intersect(a,b)
      l_ab=length(ab)
      l_a=length(a)
      l_b=length(b)
      if ((l_ab %in% c(l_a,l_b))==F){
        tot=setdiff(c(a,b),ab)
        l_tot=length(tot)
        tot=sample(tot, l_tot, replace = FALSE, prob = NULL)
        L=l_a-l_ab
        hp[[AB[1]]] = c(ab,tot[1:L])
        hp[[AB[2]]] = c(ab,tot[(L+1):l_tot])}
    }
    rm=matrix(0,R,C)
    for (row in 1:R){rm[row,hp[[row]]]=1}
    Bstar <- rm

    #Construct Pstar from Bstar
    if (sparse=="TRUE") {
      Bstar <- Matrix::Matrix(Bstar,sparse=T)
      Pstar<-Matrix::tcrossprod(Bstar)
    } else {
      Pstar <- tcrossprod(Bstar)
    }

    #Start estimation timer; print message
    if (i == 1) {
      start.time <- Sys.time()
      message("Finding the Backbone using Curveball FDSM")
    }

    #Check whether Pstar edge is larger/smaller than P edge
    Positive <- Positive + (Pstar > P)+0
    Negative <- Negative + (Pstar < P)+0

    #Save Dyad of P
    if (length(dyad) > 0){
      edge_weights[i] <- Pstar[vec[1], vec[2]]
    }

    #Report estimated running time, update progress bar
    if (i==10){
      end.time <- Sys.time()
      est = (round(difftime(end.time, start.time, units = "auto"), 2) * (trials/10))
      message("Estimated time to complete is ", est, " " , units(est))
      if (progress == "TRUE"){
        pb <- utils::txtProgressBar(min = 0, max = trials, style = 3)
      }
    }
    if ((progress == "TRUE") & (i>=10)) {utils::setTxtProgressBar(pb, i)}
  } #end for loop
  if (progress == "TRUE"){close(pb)}

  #Proporition of greater than expected and less than expected
  Positive <- (Positive/trials)
  Negative <- (Negative/trials)
  rownames(Positive) <- rownames(B)
  colnames(Positive) <- rownames(B)
  rownames(Negative) <- rownames(B)
  colnames(Negative) <- rownames(B)

  if (length(dyad) > 0){
    return(list(positive = Positive, negative = Negative, dyad_values = edge_weights))
  }

  else {
    return(list(positive = Positive, negative = Negative))
  }

} #end fdsm function
