library(car)
library(rgl)
library("RColorBrewer")
library(plot3D)

pcoa_full <- read.table(skip=9,fill = TRUE,
                                './pcoa_weighted_unifrac_rarefaction_1300_0.txt')
pcoa_full <- pcoa_full[1:(nrow(pcoa_full)-2),]
pcoa_full$V2 <- as.numeric(pcoa_full$V2)


pcoa_labs <- read.table('./NP0440-MB3_Nephele_Labels_1300.txt',header=TRUE, colClasses = "factor")
nrow(pcoa_full)

full_data <- cbind(pcoa_full, pcoa_labs)
full_data <- merge.data.frame(pcoa_full, pcoa_labs,by = 1:1)

newdata <- subset(full_data, TreatmentGroup == "Study")
group_select = as.factor(newdata$TreatmentGroup)
unilabs <- sort(unique(group_select))
pc1 <- newdata$V2
pc2 <- newdata$V3
pc3 <- newdata$V4

palette(c(brewer.pal(n=12, name = "Set3"),brewer.pal(n=12, name = "Paired"),brewer.pal(n=11, name = "Spectral")))


scatter3d(x=pc1, y=pc2, z=pc3, surface=FALSE, groups = group_select, pch=5, 
          surface.col = palette(), cex=5, axis.col = c("white", "white", "white"), 
          bg="black"
          ,labels=newdata$SampleName, id.n=nrow(newdata), id.cex=12
          #id.n=nrow(newdata), labels=newdata$SampleName, 
)



#Identify3d(x=pc1, y=pc2, z=pc3, axis.scales=TRUE, groups = NULL, labels = newdata$SampleName,
#           col = c("white"),
#           offset = ((100/length(newdata))^(1/3)) * 0.02)

plot.new()

legend("topleft",title="Color Legend",legend=unilabs,col=palette(),pch=16, cex=1.5)


dsnames <- names(pcoa_labs)
cb_options <- list()
cb_options[dsnames] <- dsnames
