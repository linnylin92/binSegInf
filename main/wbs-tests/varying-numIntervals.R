## Synopsis: Varying numIntervals and see recovery properties and conditionial
## power
source("../main/wbs-tests/plot-helpers.R")
source("../main/wbs-tests/sim-helpers.R")
outputdir = "../output"

## Now run inference simulations to see power
library(genlassoinf)
outputdir = "../output"
source("../main/wbs-tests/sim-helpers.R")
onecompare <- function(lev=0, nsim=1000, mc.cores=8, meanfun=onejump, visc=NULL,
                       numSteps=1, n=200, numIntervals=n, bits=1000){

    print("wbs.nonrand")
    result.wbs.nonrand =  mclapply(1:nsim, function(isim) {
        printprogress(isim,nsim);
        dosim_compare(type="wbs.nonrand", n=n, lev=lev, numIS=100,
                      meanfun=meanfun, visc=visc, numSteps=numSteps,
                      numIntervals=numIntervals, bits=bits)
    }, mc.cores=mc.cores)

    print("wbs.rand")
    result.wbs.rand =  mclapply(1:nsim, function(isim) {
        printprogress(isim,nsim);
        dosim_compare(type="wbs.rand", n=n, lev=lev, numIS=100,
                      meanfun=meanfun, visc=visc, numSteps=numSteps, bits=bits)
    }, mc.cores=mc.cores)
    return(list(result.wbs.nonrand=result.wbs.nonrand, result.wbs.rand=result.wbs.rand))
}


## Synopsis: Varying numIntervals and see recovery properties and conditionial
## power
source("../main/wbs-tests/plot-helpers.R")
source("../main/wbs-tests/sim-helpers.R")
outputdir = "../output"

n = 200
lev = 3
nsim = 500#100# 2000
bits = 2000
visc = unlist(lapply(c(1,2,3,4)*(n/5), function(cp)cp+c(-1,0,1)))
mc.cores = 8
numIntervals = round(seq(from=1/10,to=1.5,by=1/5)*n)
## numIntervals = round(seq(from=1/10,to=1.5,by=2/5)*n)
results.list = list()
for(ii in 1:length(numIntervals)){
    nI = numIntervals[ii]
    results.list[[ii]] = onecompare(lev=lev, nsim=nsim, meanfun=fourjump, visc=visc,
                                    numSteps=4, mc.cores=mc.cores, n=n, numIntervals=nI,
                                    bits=bits)
    ## save(list=c("results.list", "numIntervals"), file=file.path(outputdir,"varying-intervals-n200-lev1.Rdata"))
    ## save(list=c("results.list", "numIntervals"), file=file.path(outputdir,"varying-intervals-n200-lev2.Rdata"))
    save(list=c("results.list", "numIntervals"), file=file.path(outputdir,"varying-intervals-n200-lev3.Rdata"))
    ## save(list=c("results.list", "numIntervals"), file=file.path(outputdir,"varying-intervals-n20.Rdata"))
}



## Load the data
## load(file=file.path(outputdir,"varying-intervals.Rdata"))
load(file=file.path(outputdir,"varying-intervals-n200.Rdata"))

## Calculate it
avg.power.list = lapply(results.list,function(a){
    ## b = a[["result.wbs.nonrand"]]
    b = a[["result.wbs.rand"]]

    ## ## Calculate conditional power
    ## return(mean(sapply(b, function(my.b){
    ##     pvs = my.b[,"pvs"]
    ##     if(all(is.na(pvs))) return(NA)
    ##     return(sum(pvs<(0.05/length(pvs)))/length(pvs))
    ## }), na.rm=TRUE))

    ## Calculate conditional power across replicates
    verdicts = unlist(sapply(b, function(my.b){
        pvs = my.b[,"pvs"]
        if(all(is.na(pvs))) return(NA)
        ## length(pvs)
        print(pvs)
        return(pvs<(0.05/4))
    }))
    verdicts = verdicts[!is.na(verdicts)]
    return(sum(verdicts)/length(verdicts))
})

## Recovery
recoveries = lapply(results.list,
                    function(myresults){sum(sapply(myresults$result.wbs.rand,nrow))/(4*500)})

## Plot it
pdf(file=file.path(outputdir,"varying-intervals-prop-recovery-fourjump.pdf"), width=5, height=5)
## recoveries = (sapply(c(locs), function(myloc) sum(myloc %in% visc)))/nsim
props = numIntervals/n
plot(recoveries~props, type='l', ylim=c(0,1))
lines(unlist(avg.power.list)~props, col='red')
graphics.off()


## Plotting a four jump data example
set.seed(0)
sigma = 1
y0    = fourjump(n=n, lev=2) + rnorm(n,0,1)
beta0 = lapply(c(0:2), function(lev) fourjump(lev=lev, n=n))

xlab = "Location"
w = 5; h = 5
pch = 16; lwd = 2
pcol = "gray50"
ylim = c(-6,4)
mar = c(4.5,4.5,0.5,0.5)
xlim = c(0,70)

xticks = c(0,2,4,6)*10
ltys.sig = c(2,2,1)
lwd.sig = 2
pch.dat = 16
pcol.dat = "grey50"
pch.contrast = 17
lty.contrast = 2
lcol.sig = 'red'
pcol.spike=3
pcol.segment=4
pcols.delta =   pcols.oneoff = RColorBrewer::brewer.pal(n=3,name="Set2")
pch.spike = 15
pch.segment = 17
cex.contrast = 1.2

pdf(file.path(outputdir,"fourjump-example.pdf"), width=5,height=5)
par(mar=c(4.1,3.1,3.1,1.1))
plot(y0, ylim = ylim,axes=F, xlim=xlim, xlab = xlab, ylab = "", pch=pch, col=pcol);
axis(1, at = xticks, labels = xticks); axis(2)
for(ii in 1:3) lines(beta0[[ii]],col="red",lty=ltys.sig[ii], lwd=lwd.sig)
for(ii in 0:2) text(x=30,y=ii+.2, label = bquote(delta==.(ii)))
legend("bottomleft", pch=c(pch.dat,NA),
       lty=c(NA,1), lwd=c(NA,2),
       col = c(pcol.dat, lcol.sig),
       pt.cex = c(cex.contrast, NA),
       legend=c("Data", "Mean"))
title(main=expression("Data example"))
graphics.off()





## ## Detection for more complicated signal
## n = 200
## lev = 2
## nsim = 1000
## visc = unlist(lapply(c(1,2,3,4)*(n/5), function(cp){cp + c(-1,0,1)}))
## numIntervals = round(seq(from=1/10,to=1.5,by=1/5)*n)
## numSteps=4
## locs = Map(function(my.numInterval)
##     print(my.numInterval)
##     dosim_recovery(lev=lev,n=n,nsim=nsim,
##                    numSteps=numSteps,
##                    randomized=TRUE, numIS=100,
##                    meanfun=fourjump,
##                    numIntervals = my.numInterval,
##                    mc.cores=mc.cores, locs=visc), numIntervals)
## filename = "numIntervals-detection.Rdata"
## save(list=c("locs", "visc", "n", "lev", "numIntervals"),
##      file=file.path(outputdir, filename))

## ## Plot the recoveries across numIntervlas
## load(file=file.path(outputdir, filename))
## pdf(file=file.path(outputdir,"varying-intervals-detection-fourjump.pdf"), width=5, height=5)
## plot(unlist(locs)~props,type='l', ylim=c(0,1))
## graphics.off()


