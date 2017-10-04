library(car)
library("RColorBrewer")
pcoa_full <- read.table('./pcoa_weighted_unifrac_rarefaction_19631_0.txt')
pc1 <- pcoa_full$V2
pc2 <- pcoa_full$V3
pc3 <- pcoa_full$V4
colors <- c("red", "green", "white", "yellow")

pcoa_labs <- read.table('./neph_labs.txt')

scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = pcoa_labs$V14, pch=15, surface.col = colors, cex=10,
          labels = pcoa_labs$V14, id.n=nrow(pcoa_labs), axis.col = c("white", "white", "white"), bg="black")
