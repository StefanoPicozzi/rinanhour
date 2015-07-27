#!/usr/bin/Rscript

# Author: Stefano Picozzi
# Date: January 2015
# Name: 4CastR.R

# Batch control script
#Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library("ggplot2")
library("rjson")
library("plyr")
library("scales")
library("rgl")
library("xlsx")
require("grid")
library("png")

print("Building plots ...")
get4Cast <- function(config, data) {

   img <- readPNG("4CastR.png")
   g <- rasterGrob(img, interpolate=TRUE)

   img <- readPNG("legend.png")
   l <- rasterGrob(img, interpolate=TRUE)
    
   printMoney <- function(x) {
      gsub(" ", "", paste("$", format(x, digits = 10, nsmall = 0, decimal.mark = ".", big.mark = ","), sep = ""))
   }
   setZero <- function(x) { if (x > 0) {x} else {x = 0} }
   
   yLabels = c("", "", "Token", "Beauty Pageant", "Visbility", "Parity", "Advantage", "Sponsored", "Favoured", "Proven", "Top Seed", "", "")
   xLabels <- c("", "", "Experimental", "Discovery", "Championed", "Disrupters", "Project", "Hard Benefit", "Strategic", "Executive", "CXO Visibility", "", "")
   
   tickcolour <- "grey20"
   
   set.seed(123)
   N <- nrow(data)
   c00Label <- "Cover"
   c10Label <- "Convert"
   c01Label <- "Counsel"
   c11Label <- "Close"
   subTotalOffset <- 0.4
   
   data <-cbind(data, yJitter=data[,"y"]+(rnorm(N)/2), xJitter=data[,"x"]+(rnorm(N)/2))
   
   data[,"z"] <- as.numeric(data[,"z"])
   
   maxValue <- max(as.numeric(data[,"z"]))
   minValue <- 999
   
   data <- cbind(data, yLabel=data[,"yJitter"]+(data[,"z"]/maxValue/2), xLabel=data[,"xJitter"])
   data <- cbind(data, zMoney=as.character(printMoney(data[,"z"])), stringsAsFactors=FALSE)
   
   cData <- subset(data, x == config$xIntercept & y == config$yIntercept)
   c11Total <- sum(cData$z, na.rm=FALSE)
   cData <- subset(data, x == config$xIntercept & y > config$yIntercept)
   c11Total <- c11Total + sum(cData$z, na.rm=FALSE)
   cData <- subset(data, x > config$xIntercept & y == config$yIntercept)
   c11Total <- c11Total + sum(cData$z, na.rm=FALSE)   
   cData <- subset(data, x > config$xIntercept & y > config$yIntercept)
   c11Total <- c11Total + sum(cData$z, na.rm=FALSE)   
   
   cData <- subset(data, x < config$xIntercept & y == config$yIntercept)
   c01Total <- sum(cData$z, na.rm=FALSE)
   cData <- subset(data, x < config$xIntercept & y > config$yIntercept)
   c01Total <- c01Total + sum(cData$z, na.rm=FALSE)
   
   cData <- subset(data, x == config$xIntercept & y < config$yIntercept)
   c10Total <- sum(cData$z, na.rm=FALSE)
   cData <- subset(data, x > config$xIntercept & y < config$yIntercept)
   c10Total <- c10Total + sum(cData$z, na.rm=FALSE)
   
   cData <- subset(data, x < config$xIntercept & y < config$yIntercept)
   c00Total <- sum(cData$z, na.rm=FALSE)
      
   c11Total <- setZero(c11Total)
   c10Total <- setZero(c10Total)
   c01Total <- setZero(c01Total)   
   c00Total <- setZero(c00Total)
   total <- sum(data$z)
   
   data$z <- as.numeric(lapply( data$z, function(x) { if (x == 0) { x = minValue } else { x }} ))
   
   thegraph <- ggplot(data, aes(y=yJitter, x=xJitter, colour=d)) +

      scale_colour_brewer(palette="Set1", name="Grouping") +
     
      # Plotting
      # geom_point(aes(size=z, colour=d), colour="blue", fill="blue", shape=21, alpha=0.5) +   
      geom_point(aes(size=z, colour=d, fill=d), shape=20, alpha=0.7) +   
      scale_size_area(max_size=config$size, guide=FALSE) +   
      geom_text(aes(y=yLabel, x=xLabel, label=zLabel), size=4, hjust=0, vjust=0, color="grey20", fontface="bold") +
      geom_text(aes(y=yJitter, x=xJitter+0.25, label=zMoney), size=3, hjust=1, vjust=1, color="white", fontface="bold") +
      
      # Legend
      #guides(colour=FALSE) +
      theme(legend.direction="vertical", legend.position=c(0.02,0.01), legend.justification=c(1,1), legend.background = element_rect(colour="grey20"), legend.key.size = unit(0.4, "cm")) +
      guides(fill=FALSE) +     
     
      # Axis Labels
      ylab(config$yAxisTitle) + theme(axis.title.y=element_text(angle=90, size=18, face="bold")) +
      xlab(config$xAxisTitle) + theme(axis.title.x=element_text(angle=0, size=18, face="bold")) +
      
      # Axis Tick Marks
      theme(axis.ticks=element_blank()) +
      theme(axis.text.x=element_text(size=12, color="darkgray", angle=0, face="bold")) +
      # scale_x_continuous(name=config$xAxisTitle, breaks=seq(xMin,xMax,by=xGap), limits=c(xMin,xMax)) +
      # theme(axis.text.y=element_text(size=12, color="black", angle=0, face="bold")) +
      scale_x_continuous(name=config$xAxisTitle, breaks=seq(xMin-2,xMax+2,by=xGap), labels=xLabels, limits=c(xMin-2,xMax+2)) +
      theme(axis.text.x=element_text(angle=45, hjust=1, vjust=1, size=12, color=tickcolour, face="bold")) +
      scale_y_continuous(name=config$yAxisTitle, breaks=seq(yMin-2,yMax+2,by=yGap), labels=yLabels, limits=c(yMin-2,yMax+2)) +
      theme(axis.text.y=element_text(angle=45, hjust=1, vjust=1, size=12, color=tickcolour, face="bold")) +
        
      # Chart Settings
      theme(plot.background = element_rect(fill = 'grey'), panel.background = element_rect(fill = "white")) +
      ggtitle(paste(config$chartTitle, " [ Total=", printMoney(total), " ]\n", sep="")) + 
      theme(plot.title=element_text(size=15, face="bold")) +
      theme(plot.margin=unit(c(5,5,5,5), "mm")) +
      # theme(title = element_text(vjust=2)) +
      theme(legend.position=c(0.1,0.45)) + theme(legend.key.height=unit(1,"cm")) +
      annotation_custom(g, xmin=config$xMax+0.3, xmax=config$xMax+1+1.75, ymin=1.25, ymax=1+1.75) +
     
      # Grid Layout
     
      geom_hline(yintercept=(2*yMax/3)+0.5, linetype=2, alpha=0.5, color=tickcolour) +
      geom_hline(yintercept=(yMax/3)+0.5, linetype=2, alpha=0.5, color=tickcolour) +
      geom_vline(xintercept=(2*xMax/3)+0.5, linetype=2, alpha=0.5, color=tickcolour) +
      geom_vline(xintercept=(xMax/3)+0.5, linetype=2, alpha=0.5, color=tickcolour) +
      
      geom_hline(yintercept=(yMin)-0.5, linetype=2, alpha=0.5, color=tickcolour) +
      geom_hline(yintercept=(yMax)+0.5, linetype=2, alpha=0.5, color=tickcolour) +
      geom_vline(xintercept=(xMin)-0.5, linetype=2, alpha=0.5, color=tickcolour) +
      geom_vline(xintercept=(xMax)+0.5, linetype=2, alpha=0.5, color=tickcolour) +
      
      annotate("segment", x=config$xIntercept, xend=config$xIntercept, y=yMin-1.75, yend=yMax+1.75, size=2, alpha=0.5, color=tickcolour) +
      annotate("segment", y=config$yIntercept, yend=config$yIntercept, x=xMin-1.75, xend=xMax+1.75, size=2, alpha=0.5, color=tickcolour) +
   
      annotate("text", x=config$xMax+2, y=config$yMax+2, label=c11Label, size=6, fontface="bold.italic", hjust=1) +
      annotate("text", x=config$xMax+2, y=config$yMin-2, label=c10Label, size=6, fontface="bold.italic", hjust=1) +   
      annotate("text", x=config$xMin-2, y=config$yMin-2, label=c00Label, size=6, fontface="bold.italic", hjust=0) +
      annotate("text", x=config$xMin-2, y=config$yMax+2, label=c01Label, size=6, fontface="bold.italic", hjust=0) +
      
      annotate("text", x=config$xMax+2, y=config$yMax+2-subTotalOffset, label=printMoney(c11Total), size=4, fontface="bold", hjust=1) +
      annotate("text", x=config$xMax+2, y=config$yMin-2+subTotalOffset, label=printMoney(c10Total), size=4, fontface="bold", hjust=1) +
      annotate("text", x=config$xMin-2, y=config$yMin-2+subTotalOffset, label=printMoney(c00Total), size=4, fontface="bold", hjust=0) +
      annotate("text", x=config$xMin-2, y=config$yMax+2-subTotalOffset, label=printMoney(c01Total), size=4, fontface="bold", hjust=0) +   

      annotate("text", x=config$xMin+1.5, y=config$yMin-2, label="BEGINNING", size=4, fontface="bold", hjust=1) +
      annotate("text", x=(config$xMax/3)+2.4, y=config$yMin-2, label="MIDDLE", size=4, fontface="bold", hjust=1) +
      annotate("text", x=(2*config$xMax/3)+2, y=config$yMin-2, label="END", size=4, fontface="bold", hjust=1) +

      annotate("text", x=(config$xMin)-2, y=(2*config$yMax/3)+2.6, label="FAVOURITE", size=4, fontface="bold", hjust=0, vjust=1, angle=270) +
      annotate("text", x=(config$xMin)-2, y=(config$yMax/3)+3.1, label="CONTENDER", size=4, fontface="bold", hjust=0, vjust=1, angle=270) +
      annotate("text", x=(config$xMin)-2, y=(config$yMin)+1.4, label="OUTSIDER", size=4, fontface="bold", hjust=0, vjust=1, angle=270)       

   print(thegraph)
   
}





