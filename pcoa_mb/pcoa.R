library(car)
library("RColorBrewer")
pcoa_full <- read.table('./pcoa_weighted_unifrac_rarefaction_10000_0.txt')
pc1 <- pcoa_full$V2
pc2 <- pcoa_full$V3
pc3 <- pcoa_full$V4

pcoa_labs <- read.table('./neph_labs.txt')

#Create palette of colors
palette(c(brewer.pal(n=12, name = "Set3"),brewer.pal(n=12, name = "Paired"),brewer.pal(n=11, name = "Spectral")))
choice <- V4

scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = pcoa_labs$choice, pch=15, surface.col = palette(), cex=10,
          labels = pcoa_labs$V4, id.n=nrow(pcoa_labs), axis.col = c("white", "white", "white"), bg="black")

