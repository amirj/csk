
getlocalsimframe <- function(feature_matrix, df_sim_pairs) {
  gold <- c()
  alg  <- c()
  label <- c()
  for(i in 1:nrow(df_sim_pairs)){
    e1 <- as.character(df_sim_pairs[i,"id1"])
    e2 <- as.character(df_sim_pairs[i,"id2"])
    label <- append(label, paste(e1, e2, sep=":"))
    gold  <- append(gold, df_sim_pairs[i,"sim"])
    s <- cosine(feature_matrix[e1,], feature_matrix[e2,])[1,1]
    alg  <- append(alg, s)
  }
  dplot <- data.frame(label,gold,alg)
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
    scale_x_continuous(breaks = 0:10,
                       limits = c(0,10),
                       expand = c(.05,.05))+
    scale_y_continuous("")
  empty <- ggplot()+geom_point(aes(1,1), colour="white") +
    theme(axis.ticks=element_blank(), 
          panel.background=element_blank(), 
          axis.text.x=element_blank(), axis.text.y=element_blank(),           
          axis.title.x=element_blank(), axis.title.y=element_blank())  
  scatter <- ggplot()+geom_point(aes(human, algorithm)) +
    scale_x_continuous(breaks = 0:10,
                       limits = c(0,10),
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

