###Load the data
d<-read.csv("http://www.dimiter.eu/Visualizations_files/imdb/ratings.csv")

###Data manipulation
d<-subset(d,d$Title.type=='Feature Film')

d$mine<-d$You.rated
d$imdb<-d$IMDb.Rating
d$year<-as.factor(ifelse( d$Year<1970, '1960s',ifelse( d$Year<1980, '1970s',ifelse( d$Year<1990, '1980s',ifelse( d$Year<2000, '1990s',ifelse( d$Year<2010, '2000s',ifelse( d$Year<2020, '2010s',NA)))))) )
d$time<-log(d$Runtime..mins.)
d$votes<-d$Num..Votes
d$year.c<-2014-d$Year

for (i in 1: max(nrow(d))){
  temp<-strsplit(as.character(d$Genres[i]), ",")
  d[i, "Genre.N"]<-length(temp[[1]])
  for (j in 1:length(temp[[1]])){
    d[i,paste("Genre",j,sep=".")]<-temp[[1]][j]
  }
  
}
d$Genre.1<-as.factor(gsub(" ","", d$Genre.1))
d$Genre.2<-as.factor(gsub(" ","", d$Genre.2))
d$Genre.3<-as.factor(gsub(" ","", d$Genre.3))
d$Genre.4<-as.factor(gsub(" ","", d$Genre.4))
d$Genre.5<-as.factor(gsub(" ","", d$Genre.5))

d$Genre.1 <- as.factor(ifelse(is.na(d$Genre.1)==T, "0",as.character(d$Genre.1))) 
d$Genre.2 <- as.factor(ifelse(is.na(d$Genre.2)==T, "0",as.character(d$Genre.2))) 
d$Genre.3 <- as.factor(ifelse(is.na(d$Genre.3)==T, "0",as.character(d$Genre.3))) 
d$Genre.4 <- as.factor(ifelse(is.na(d$Genre.4)==T, "0",as.character(d$Genre.4))) 
d$Genre.5 <- as.factor(ifelse(is.na(d$Genre.5)==T, "0",as.character(d$Genre.5))) 

t<-unique(c(as.character(unique(d["Genre.1"])$Genre.1), as.character(unique(d["Genre.2"])$Genre.2),
            as.character(unique(d["Genre.3"])$Genre.3),as.character(unique(d["Genre.4"])$Genre.4),
            as.character(unique(d["Genre.5"])$Genre.5)))
t<-t[-c(8,9,11,13,14,15, 16,18,19,20,21,22)]


for (i in 1:length(t)){
  for (j in 1: nrow(d)){
    
    if (d[j,"Genre.1"]==t[i] | d[j,"Genre.2"]==t[i] | d[j,"Genre.3"]==t[i] | d[j,"Genre.4"]==t[i] | d[j,"Genre.5"]==t[i]) 
      d[j,paste(t[i],"","")]<-1
    else
      d[j,paste(t[i],"","")]<-0
  }
}

for (i in 1:nrow(d)){
  if (d$adventure[i]==1 | d$sci_fi[i]==1)
    d$new.genre[i]<-'adventure'
  else
    if (d$comedy[i]==1 | d$action[i]==1 | d$romance[i]==1)
      d$new.genre[i]<-'light'
    else
      if (d$drama[i]==1 | d$biography[i]==1 | d$crime[i]==1 | d$mystery[i]==1 | d$thriller[i]==1)
        d$new.genre[i]<-'serious'
      else
        d$new.genre[i]<-'other'
}


for (i in 1:nrow(d)){
  if (d$adventure[i]==1)
    d$short.genre[i]<-'adventure'
  else
    if (d$sci_fi[i]==1)
      d$short.genre[i]<-'sci_fi'
    else
      if (d$biography[i]==1)
        d$short.genre[i]<-'biography'
      else
        if (d$mystery[i]==1)
          d$short.genre[i]<-'mystery'
        else
          if (d$thriller[i]==1)
            d$short.genre[i]<-'thriller'
          else
            if (d$crime[i]==1)
              d$short.genre[i]<-'crime'
            else
              if (d$drama[i]==1)
                d$short.genre[i]<-'drama'
              else
                if (d$comedy[i]==1)
                  d$short.genre[i]<-'comdedy'
                else
                  if (d$romance[i]==1)
                    d$short.genre[i]<-'romance'
                  else
                    if (d$action[i]==1)
                      d$short.genre[i]<-'action'
                    else
                      d$short.genre[i]<-'other'
}


r<-row.names(as.data.frame(sort(table(d$Directors), decreasing = TRUE)[1:12]))
for (i in 1:length(r)){
  for (j in 1: nrow(d)){
    
    if (d[j,"Directors"]==r[i] ) 
      d[j,paste(r[i],"","")]<-1
    else
      d[j,paste(r[i],"","")]<-0
  }
}

attach(d)

###Data analysis

library(ggplot2)
#Figure 1
p<-ggplot(d, aes(x=mine))+
  geom_density(alpha=0.5,aes(x=mine, y = ..density..,fill='blue'))+
  geom_density(alpha=0.5,aes(x=imdb, y = ..density..,fill='red'))+
  geom_histogram(aes(y=..count../sum(..count..)))+
  scale_x_continuous('IMDb ratings',breaks=seq(2,10,1))+
  scale_y_continuous('Density')+
  theme_bw()+theme(legend.position="none")

png(file="./results/figure1.png",width = 169, height = 100, units = "mm", res = 180)
p
dev.off()

#Linear model 1
summary(m1<-lm(mine~imdb, data=d))

#Figure 2
p <- ggplot(d, aes(imdb, mine))+
  geom_point(position=position_jitter(width=0.1,height=.25),shape=16, size=4,alpha=0.6,
             aes(colour = new.genre, ))+
  stat_smooth(se = TRUE)+
  scale_x_continuous('IMDb ratings')+
  scale_y_continuous('My ratings')+
  theme_bw()+
  scale_colour_discrete(name="Genre")+
  scale_size_continuous(guide=FALSE)+
  theme(legend.position=c(0.15, 0.80))+
  geom_abline(size=1, aes(intercept=-0.6387, slope=0.9686))

png(file="./results/figure2.png",width = 169, height = 100, units = "mm", res = 180)
p
dev.off()


sqrt(mean(residuals(m1)^2)) #root mean squared error: 1.25

#Shalizi function for prediction limits, http://www.stat.cmu.edu/~cshalizi/uADA/13/lectures/ch09.pdf
predlims <- function(preds,sigma) {
  prediction.sd <- sqrt(preds$se.fit^2+sigma^2)
  upper <- preds$fit+2*prediction.sd
  lower <- preds$fit-2*prediction.sd
  lims <- cbind(lower=lower,upper=upper)
  return(lims)
}

preds.lm <- predict(m1,se.fit=TRUE)
predlims.lm <- predlims(preds.lm,sigma=summary(m1)$sigma)
mean(d$mine <= predlims.lm[,"upper"]
     & d$mine >= predlims.lm[,"lower"]) #coverage of the prediction 96%


#Figure 3. Based on Shalizi, Chapter 09, http://www.stat.cmu.edu/~cshalizi/uADA/13/lectures/ch09.pdf
png(file="./results/figure3.png",width = 169, height = 120, units = "mm", res = 180)
plot(d$mine,preds.lm$fit,type="n", xlim=c(2,10), ylim=c(2,10),
     xlab="My actual ratings",ylab="Predicted ratings", main="")
segments(d$mine,predlims.lm[,"lower"],
         d$mine,predlims.lm[,"upper"], col="grey")
abline(a=0,b=1,lty="dashed")
points(d$mine,preds.lm$fit,pch=16,cex=0.8)
dev.off()

#Figure 4
d1<-subset(d, d$imdb>6.49 & d$imdb<7.5)
d2<-subset(d, d$imdb>7.51 & d$imdb<8.5)

p<-ggplot (NULL, aes(mine))+
  geom_density(data = d1, fill='blue', alpha=0.4,aes(x=mine, y = ..density..))+
  geom_density(data = d2, fill='red', alpha=0.4,aes(x=mine, y = ..density..))+
  scale_x_continuous('My ratings for different values of IMDb scores (blue: 6.5-7.5, red:7.5-8.5)',breaks=seq(2,10,1))+
  scale_y_continuous('Density')+
  theme_bw()+theme(legend.position="none")

png(file="./results/figure4.png",width = 169, height = 100, units = "mm", res = 180)
p
dev.off()


#Linear model 2
summary(m2<-lm(mine~imdb+d$comedy +d$romance+d$mystery+d$"Stanley Kubrick"+d$"Lars Von Trier"+d$"Darren Aronofsky"+year.c, data=d))
sqrt(mean(residuals(m2)^2)) #root mean squared error: 1.14

preds.lm <- predict(m2,se.fit=TRUE)
predlims.lm <- predlims(preds.lm,sigma=summary(m2)$sigma)
mean(d$mine <= predlims.lm[,"upper"]
     & d$mine >= predlims.lm[,"lower"]) #coverage of the prediction 96%

#Figure 5. Based on Shalizi, Chapter 09, http://www.stat.cmu.edu/~cshalizi/uADA/13/lectures/ch09.pdf
png(file="./results/figure5.png",width = 169, height = 120, units = "mm", res = 180)
plot(d$mine,preds.lm$fit,type="n", xlim=c(2,10), ylim=c(2,10),
     xlab="My actual ratings",ylab="Predicted ratings", main="")
segments(d$mine,predlims.lm[,"lower"],
         d$mine,predlims.lm[,"upper"], col="grey")
abline(a=0,b=1,lty="dashed")
points(d$mine,preds.lm$fit,pch=16,cex=0.8)
dev.off()

#Figure 6. 
d.60<-subset(d, Year>1960)
d.60$r<-residuals(lm(d.60$mine~d.60$imdb))

summary(lm(d.60$r~d.60$Year))
p <- ggplot(d.60, aes(Year, r))+
  geom_point(position=position_jitter(width=0.1,height=.25),shape=16, size=4,alpha=0.6,
             aes(colour = new.genre, ))+
  stat_smooth()+
  scale_x_continuous('Year of release')+
  scale_y_continuous('My ratings (residuals)')+
  theme_bw()+
  scale_colour_discrete(name="Genre")+
  scale_size_continuous(guide=FALSE)+
  theme(legend.position=c(0.15, 0.15))+
  geom_abline(size=1, aes(intercept=33.33, slope=-0.016659))

png(file="./results/figure6.png",width = 169, height = 100, units = "mm", res = 180)
p
dev.off()

#GAMs
library(mgcv)
m3 <- gam(mine ~ s(imdb), data = d)
summary(m3)
plot(m3,scale=0,se=2,shade=TRUE,pages=1)


m4<-gam(mine ~ te(imdb, year.c)+d$"comedy " +d$"romance "+d$"mystery "+d$"Stanley Kubrick"+d$"Lars Von Trier"+d$"Darren Aronofsky", data = d) 
summary(m4)

png(file="./results/figure7.png",width = 169, height = 100, units = "mm", res = 180)
plot(m4,select=1,theta=-18,phi=15,pers=TRUE)
dev.off()

sqrt(mean(residuals(m4)^2)) #root mean squared error


###Categorical data analysis

for (i in 1:nrow(d)){
  if (d$mine[i]<5)
    d$mine.c[i]<-5
  else
    if (d$mine[i]>9)
      d$mine.c[i]<-9
    else
      d$mine.c[i]<-d$mine[i]
}

#Non-parametric plot
library(vcd)
png(file="./results/figure8.png",width = 169, height = 100, units = "mm", res = 180)
#(spine(as.factor(mine.c) ~ imdb, breaks='Scott',data = d))
cdplot(as.factor(mine.c) ~ imdb, xlab='IMDb rating', ylab='My rating', data = d)
with(d, rug(jitter(d$imdb), col="white", quiet=TRUE))
dev.off()

### Parametric model
#a linear regression with the recoded variable for comparison 
summary(m2.c<-lm(mine.c~imdb+d$"comedy " +d$"romance "+d$"mystery "+d$"Stanley Kubrick"+d$"Lars Von Trier"+d$"Darren Aronofsky"+year.c, data=d))
library(MASS)

m5 <- polr(as.factor(mine.c) ~ imdb+d$"comedy " +d$"romance "+d$"mystery "+d$"Stanley Kubrick"+d$"Lars Von Trier"+d$"Darren Aronofsky"+year.c,  Hess=TRUE, data = d)
m5.c <- polr(as.factor(mine.c) ~ imdb+year.c,  Hess=TRUE, data = d)

summary(m5.c)

library(effects)
png(file="./results/figure9.png",width = 169, height = 100, units = "mm", res = 180)
plot(effect("imdb",m5.c), style="stacked", xlab="IMDb rating", ylab="Predicted probability of my rating", main="", key.args = list(x=0.05, y=0.25))
dev.off()

###Check precision for subsets
d9<-subset(d, (d$imdb>5.9 & d$imdb<6.1) | (d$imdb>6.9 & d$imdb<7.1) | (d$imdb>7.9 & d$imdb<8.1)| (d$imdb>8.9 & d$imdb<9.1))
d10<-subset(d, (d$imdb>6.4 & d$imdb<6.6) | (d$imdb>7.4 & d$imdb<7.6) | (d$imdb>8.4 & d$imdb<8.6)| (d$imdb>5.4 & d$imdb<5.6))
summary(m9<-lm(mine~imdb, data=d9))
summary(m10<-lm(mine~imdb, data=d10))
sqrt(mean(residuals(m9)^2))
sqrt(mean(residuals(m10)^2))

###THE END 
