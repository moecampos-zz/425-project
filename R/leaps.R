source('./R/cleaning.R')

og <- ls()

X <- listings[,c("avail","num_reviews","rpm","min_nights","nb","room_type")]
#Y <- listings[,"price"]
Y <- listings[,"price"]^-0.4

b0 <- BIC(lm(Y~1))
a0 <- AIC(lm(Y~1))
vb0 <- 0
va0 <- 0

aa <- Inf
bb <- Inf
for(i in 1:ncol(X)) {
  b1 <- BIC(lm(Y~X[,i]))
  a1 <- AIC(lm(Y~X[,i]))
  if(b1 < bb) {bb <- b1; vb1 <- i}
  if(a1 < aa) {aa <- a1; va1 <- i}
}
b1 <- bb
a1 <- aa

aa <- Inf
bb <- Inf
for(i in 1:(ncol(X)-1)) {
  for(j in (i+1):ncol(X)) {
    b2 <- BIC(lm(Y~X[,i]+X[,j]))
    a2 <- AIC(lm(Y~X[,i]+X[,j]))
    if(b2 < bb) {bb <- b2; vb2 <- c(i,j)}
    if(a2 < aa) {aa <- a2; va2 <- c(i,j)}    
  }
}
b2 <- bb
a2 <- aa

aa <- Inf
bb <- Inf
for(i in 1:4) {
  for(j in (i+1):5) {
    for(k in (j+1):6) {
      b3 <- BIC(lm(Y~X[,i]+X[,j]+X[,k]))
      a3 <- AIC(lm(Y~X[,i]+X[,j]+X[,k]))
      if(b3 < bb) {bb <- b3; vb3 <- c(i,j,k)}
      if(a3 < aa) {aa <- a3; va3 <- c(i,j,k)} 
    }
  }
}
b3 <- bb
a3 <- aa

aa <- Inf
bb <- Inf
for(i in 1:3) {
  for(j in (i+1):4) {
    for(k in (j+1):5) {
      for(l in (k+1):6) {
        b4 <- BIC(lm(Y~X[,i]+X[,j]+X[,k]+X[,l]))
        a4 <- AIC(lm(Y~X[,i]+X[,j]+X[,k]+X[,l]))
        if(b4 < bb) {bb <- b4; vb4 <- c(i,j,k,l)}
        if(a4 < aa) {aa <- a4; va4 <- c(i,j,k,l)}
      }
    }
  }
}
b4 <- bb
a4 <- aa


aa <- Inf
bb <- Inf
for(i in 1:2) {
  for(j in (i+1):3) {
    for(k in (j+1):4) {
      for(l in (k+1):5) {
        for(m in (l+1):6) {
          b5 <- BIC(lm(Y~X[,i]+X[,j]+X[,k]+X[,l]+X[,m]))
          a5 <- AIC(lm(Y~X[,i]+X[,j]+X[,k]+X[,l]+X[,m]))
          if(b5 < bb) {bb <- b5; vb5 <- c(i,j,k,l,m)}
          if(a5 < aa) {aa <- a5; va5 <- c(i,j,k,l,m)}
        }
      }
    }
  }
}
b5 <- bb
a5 <- aa

b6 <- BIC(lm(Y~X[,1]+X[,2]+X[,3]+X[,4]+X[,5]+X[,6]))
a6 <- AIC(lm(Y~X[,1]+X[,2]+X[,3]+X[,4]+X[,5]+X[,6]))
vb6 <- 1:6
va6 <- 1:6

varsb <- c(paste(vb0,collapse = ''),paste(vb1,collapse = ''),paste(vb2,collapse = ''),
          paste(vb3,collapse = ''),paste(vb4,collapse = ''),paste(vb5,collapse = ''),
          paste(vb6,collapse = ''))
varsa <- c(paste(va0,collapse = ''),paste(va1,collapse = ''),paste(va2,collapse = ''),
           paste(va3,collapse = ''),paste(va4,collapse = ''),paste(va5,collapse = ''),
           paste(va6,collapse = ''))

aic <- c(a0,a1,a2,a3,a4,a5,a6)
bic <- c(b0,b1,b2,b3,b4,b5,b6)
p <- 0:6

final <- ls()[ls() %in% og == FALSE] 

var.sel <- data.frame(p,aic,varsa,bic,varsb)
rm(list = final)

print(var.sel)

#Best BIC model is the one with "avail","rpm","min_nights","nb","room_type".
#Best AIC model is the full model. However, the best BIC model is the second best AIC model.
