library(car)
library(rgl)
library("RColorBrewer")

pcoa_full <- read.table('./pcoa_weighted_unifrac_rarefaction_10000_0.txt')
pc1 <- pcoa_full$V2
pc2 <- pcoa_full$V3
pc3 <- pcoa_full$V4
pcoa_labs <- read.table('./NP0452-MB6_Nephele_Labels_10000.txt',header=TRUE, colClasses = "factor")

palette(c(brewer.pal(n=12, name = "Set3"),brewer.pal(n=12, name = "Paired"),brewer.pal(n=11, name = "Spectral")))

group_select = as.factor(pcoa_labs$Lot_Primer)
unilabs <- sort(unique(group_select))

scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, surface.col = palette(), cex=5,
          axis.col = c("white", "white", "white"), bg="black")
plot.new()
legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)
