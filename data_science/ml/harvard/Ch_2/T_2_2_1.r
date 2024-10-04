# set.seed(1) # if using R 3.5 or earlier
set.seed(1, sample.kind = "Rounding") # if using R 3.6 or later
disease <- sample(c(0,1), size=1e6, replace=TRUE, prob=c(0.98,0.02))
test <- rep(NA, 1e6)
test[disease==0] <- sample(c(0,1), size=sum(disease==0), replace=TRUE, prob=c(0.90,0.10))
test[disease==1] <- sample(c(0,1), size=sum(disease==1), replace=TRUE, prob=c(0.15, 0.85))

q2 <- sum(test) / length(test)
q2

q3 <- sum(test[disease==1]==0) / sum(test==0)
q3

q4 <- sum(test[disease==1]==1) / sum(test==1)
q4

q5 <- q4 / 0.02
q5