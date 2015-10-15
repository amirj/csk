getvid <- function(graph, title)
{
  return(V(graph)[V(graph)$id == title])
}

getindex <- function(i, j, N) {
  r <- min(i, j)
  c <- max(i, j)
  index <- N * (r - 1) + c - ((r - 1) * r / 2) - r;
  return(index)
}

lin <- function(x, y){
  s <- 0
  for(i in 1:length(x)){
    if(x[i] > 0 & y[i] > 0)
      s <- s + x[i] + y[i]
  }
  return(s/(sum(x)+sum(y)))
}

acosine <- function(x, y){
  return((crossprod(x, y)/sqrt(max(crossprod(x), crossprod(y))))[1,1])
}

getsimframe <- function(FM, zerofy, doc_concept, method) {
  m <- as.matrix(FM)
  n <- as.matrix(doc_concept)
  lfm <- list()
  l <- list()
  for(row in 1:nrow(FM)){
    lfm[[row]] <- m[row,]
    l[[row]] <- n[row,]
  }
  algsims <- as.matrix(simil(lfm, method=method, upper=T))
  bsims <- as.matrix(simil(l, method=method, upper=T))
  lspacealg <- cosine(as.textmatrix(lsa(t(m))))
  lspacebcos <- cosine(as.textmatrix(lsa(t(n))))
  simtbl <- read.csv("sim.tbl")
  gold <- c()
  alg  <- c()
  lsaalg <- c()
  bcos <- c()
  lsabcos <- c()
  label <- c()
  for(i in 1:50)
    for(j in 1:50){
      if(j > i){
        gold <- append(gold, simtbl[i,j])
        s <- algsims[i,j]
        if(zerofy && is.nan(s))
          s <- 0
        alg  <- append(alg, s)
        lsaalg <- append(lsaalg, lspacealg[i,j])
        s <- bsims[i,j]
        bcos  <- append(bcos, s)
        lsabcos <- append(lsabcos, lspacebcos[i,j])
        label <- append(label, paste(getindex(i,j,50),"=(", i, ",", j, ")", sep=""))
      }
    }
  dplot <- data.frame(gold,alg,lsaalg,bcos,lsabcos,label)
  return(dplot)
}

getlocalsimframe <- function(doc_concept, km) {
  simtbl <- read.csv("sim.tbl")
  gold <- c()
  alg  <- c()
  bcos <- c()
  label <- c()
  n <- as.matrix(doc_concept)
  for(i in 1:50)
    for(j in 1:50){
      if(j > i){
        gold <- append(gold, simtbl[i,j])
        FM <- data.frame(matrix(0, nrow=2, ncol=ncol(km)), 
                         row.names=c(as.character(i),as.character(j)))
        names(FM) <- names(km)
        seedsi <- names(doc_concept)[which(doc_concept[as.character(i),] > 0)]
        seedsj <- names(doc_concept)[which(doc_concept[as.character(j),] > 0)]
        seeds <- union(seedsi, seedsj)
        df <- km[seeds,]
        dfi <- km[seedsi,]
        dfj <- km[seedsj,]
        for(col in names(df)){
          if(length(which(df[,col]>0)) > 1){
            FM[as.character(i),col] <- sum(dfi[,col])
            FM[as.character(j),col] <- sum(dfj[,col])
          }
        }
        m <- as.matrix(FM)
        s <- cosine(m[1,], m[2,])[1,1]
        alg  <- append(alg, s)
        s <- cosine(n[i,], n[j,])[1,1]
        bcos  <- append(bcos, s)
        label <- append(label, paste(getindex(i,j,50),"=(", i, ",", j, ")", sep=""))
      }
    }
  dplot <- data.frame(gold,alg,bcos,label)
  return(dplot)
}

# compute text relatedness and calculate r/rho corelations
correlation <- function(dsim, rtype = "pearson") {
  .e <- globalenv()
  .e$human <- dsim$gold
  .e$algorithm <- dsim$alg
  hist_top <- ggplot()+geom_histogram(aes(human))+
    theme(legend.position = "none",
          axis.title.x = element_blank(),
          axis.text.x = element_blank())+
    scale_x_continuous(breaks = 0:5,
                       limits = c(0,5),
                       expand = c(.05,.05))+
    scale_y_continuous("")
  empty <- ggplot()+geom_point(aes(1,1), colour="white") +
    theme(axis.ticks=element_blank(), 
          panel.background=element_blank(), 
          axis.text.x=element_blank(), axis.text.y=element_blank(),           
          axis.title.x=element_blank(), axis.title.y=element_blank())  
  scatter <- ggplot()+geom_point(aes(human, algorithm)) +
    scale_x_continuous(breaks = 0:5,
                       limits = c(0,5),
                       expand = c(.05,.05))+
    scale_y_continuous(breaks = c(0.0,0.2,0.4,0.6,0.8,1.0),
                       limits = c(0,1),
                       expand = c(.05,.05))
  hist_right <- ggplot() + geom_histogram(aes(algorithm)) + coord_flip() +
    theme(legend.position = "none",
          axis.title.y = element_blank(),
          axis.text.y = element_blank()) +
    scale_x_continuous(breaks = c(0.0,0.2,0.4,0.6,0.8,1.0),
                       limits = c(0,1),
                       expand = c(.05,.05)) +
    scale_y_continuous("", breaks=c(0,500,1000))
  grid.arrange(hist_top, empty, scatter, hist_right, ncol=2, nrow=2, widths=c(4, 1), heights=c(1, 4))
  return(rcorr(human, algorithm, rtype))
}

# count the occurences of a needle in a haystack
count <- function(haystack, needle){
  v = attr(gregexpr(needle, haystack, fixed = T)[[1]], "match.length")
  if (identical(v, -1L)) 0 else length(v)
}

# find the maximum clique
getmaxcliques <- function(){
  max <- 0
  for(t in names(km))
  {
    if(count(t, ":") > max)
      max <- count(t, ":")
  }
  return(max + 1)
}

# extract a n-clique kernel matrix
getncliques <- function(n){
  cols <- character()
  for(t in names(km)){
    c <- count(t, ":") + 1
    if(c == n){
      cols <- append(cols, t)
    }
  }
  return(length(cols))
}

for(i in 1:31){
  t[i] <- getncliques(i + 1)
}



findworstsims <- function(sim){
  sim["diff"] <- abs(sim$alg - sim$gold)
  orderedsim <- sim[with(sim,order(-diff)),]
  return(orderedsim)
}

gettopkfeatures <- function(docid, FM, k){
  return(sort(FM[docid,],decreasing=T)[1:k])
}

getfeatures <- function(docid, FM, feature){
  ff <- character()
  count <- c()
  for(c in colnames(FM)){
    if(FM[docid,c] == 0)
      next
    features <- unlist(strsplit(c, ":"))
    if(feature %in% features){
        ff <- append(ff,c)
        count <- append(count,FM[docid,c])
    }
  }
  return(data.frame(ff,count))
}
