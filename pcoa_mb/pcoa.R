library(car)
library(rgl)
library("RColorBrewer")
library(plot3D)

pcoa_full <- read.table('./pcoa_weighted_unifrac_rarefaction_1300_0.txt')
pc1 <- pcoa_full$V2
pc2 <- pcoa_full$V3
pc3 <- pcoa_full$V4
pcoa_labs <- read.table('./NP0440-MB3_Nephele_Labels_1300.txt',header=TRUE, colClasses = "factor")

palette(c(brewer.pal(n=12, name = "Set3"),brewer.pal(n=12, name = "Paired"),brewer.pal(n=11, name = "Spectral")))

full_data <- cbind(pcoa_full, pcoa_labs)
newdata <- subset(full_data, TreatmentGroup == "Study")
group_select = as.factor(newdata$TreatmentGroup)
unilabs <- sort(unique(group_select))
pc1 <- newdata$V2
pc2 <- newdata$V3
pc3 <- newdata$V4

scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, 
          surface.col = palette(), cex=5, axis.col = c("white", "white", "white"), 
          bg="black", labels=newdata$TreatmentGroup, id.n=nrow(newdata)
)

plot.new()
legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)

