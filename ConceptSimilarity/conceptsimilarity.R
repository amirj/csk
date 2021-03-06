# set global options
options(digits=3)

# Add required libraries
library(igraph)
library(lattice)
library(Matrix)
library(Hmisc)
library(MASS)
library(ggplot2)
library(gridExtra)
library(lsa)
library(tm)

# load required sources
source("utils.R")

# load concept-sim data set
concept_sim <- read.csv(file="conceptsim.csv", sep=",", check.names=F)

# load the local WordNet graph
graph <- read.graph("G.net", format="pajek")
V(graph)$name <- V(graph)$id

# build data matrix
D <- as.matrix(get.adjacency(graph, names = T))
u <- as.character(unique(unlist(concept_sim[c("id1","id2")])))
D <- D[u,]

# create a local similarity frame <label,gold,alg>
sim <- getlocalsimframe(feature_matrix=D, df_sim_pairs=concept_sim)

# compute baseline correlation: 0.41 (see Table R_overlap in Table 3)
correlation(dsim=sim, rtype="spearman")

# ----------------------------------------------------------
# extract all maximal cliques
l <- maximal.cliques(graph=graph, min=2, max=NULL)

# create an empty Clique Kernel <Concept,Clique> (Kernel Matrix)
K <- data.frame(matrix(0, nrow = ncol(D), ncol = length(l)),
                 row.names=colnames(D))
C <- character()
for(c in l){
  C <- append(C, paste(V(graph)[c]$id, collapse=":"))
}
names(K) <- C

# fill Kernel Matrix
vocab <- row.names(K)
for(c in l){
  clique <- V(graph)[c]$id
  colname <- paste(V(graph)[c]$id, collapse=":")
  for(t in clique){
    if(t %in% vocab)
      K[t,colname] <- K[t,colname] + 1
  }
}

# calculate different kernel matrixes
km <- K

# skip empty cliques: no empty clique
notempty <- c()
for(colname in names(km)){
  if(length(which(km[,colname] > 0)) > 1)
    notempty <- append(notempty, colname)
}
km <- km[,notempty]

# IDF normalization of the kernel matrix: 0.61 (be patient, it takes long time!)
k <- length(names(km))
for(rowname in row.names(km)){
  idf <- 1 + length(which(km[rowname,] > 0))
  km[rowname,] <- km[rowname,] * log10(k/idf)
  if(idf == 1)
    print(rowname)
}

# building the feature matrix using the kernel matrix
FM <- as.matrix(D) %*% as.matrix(km)

# IDF normalization of the feature matrix: 0.61 (see Table CSK in Table 3)
C <- nrow(FM)
for(colname in colnames(FM)){
  idf <- 1 + length(which(FM[,colname] > 0))
  FM[,colname] <- FM[,colname] * log10(C/idf)
}

# create a local similarity frame <label,gold,alg>
fsim <- getlocalsimframe(feature_matrix=FM, df_sim_pairs=concept_sim)

# compute correlation
correlation(dsim=fsim, rtype="spearman")
