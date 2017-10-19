library(car)
library(rgl)
library("RColorBrewer")

pcoa_full <- read.table('./pcoa_weighted_unifrac_rarefaction_10000_0.txt')
pc1 <- pcoa_full$V2
pc2 <- pcoa_full$V3
pc3 <- pcoa_full$V4

pcoa_labs <- read.table('./NP0452-MB6_Nephele_Labels_10000.txt')
names <- unique(pcoa_labs$V3)

#Create palette of colors
palette(c(brewer.pal(n=12, name = "Set3"),brewer.pal(n=12, name = "Paired"),brewer.pal(n=11, name = "Spectral")))


scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = pcoa_labs$V3, pch=5, surface.col = palette(), cex=5,
          labels = pcoa_labs$V3, id.n=nrow(pcoa_labs), 
          axis.col = c("white", "white", "white"), bg="black")

text3d(x=1.4, y=c(.9,.95,1,1.05,1.1), z=1.1, unique(pcoa_labs$V3) ,col="white")
points3d(x=1.2,y=c(.9,.95,1,1.05,1.1),z=1.1, col=palette(), size=5)
