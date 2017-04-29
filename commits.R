setwd('/Users/zubin/Documents/NCSU/Courses/CSC 510 - Software Engineering/Bad-Smells')
commits <- read.csv('commits.csv')

commits$created_at <- strptime(as.character(commits$created_at),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")
commits$created_by <- as.character(commits$created_by)

commits_per_team <-  sort(table(commits$team))

# Barplot of number of commits per team
b <- barplot(commits_per_team,ylim=c(0,400),main="Total number of commits per team")
# text(b,unname(commits_per_team),pos = 3)

# Plot pie chart of percentage of commits per user within a team
# teams <- unique(commits$team)
# n <- length(teams)
# close.screen(all.screens = TRUE)
# split.screen(c(3,4))
# for (i in 1:n) {
#     screen(i)
#     pie(table(commits[commits$team==teams[i],]$created_by))
# }

# close.screen(all.screens = TRUE)

# barplot(table(commits$created_by,commits$team),legend.text = TRUE)

# Create a table of users per team, and create percentages
x <- table(commits$created_by,commits$team)
for (i in 1:ncol(x)) {
    x[,i] <- x[,i]/sum(x[,i])
}

barplot(x,legend.text = TRUE,args.legend = list(x="top",inset=c(0,-0.2),horiz=TRUE))


# Get numbers of commits per week
startTime <- strptime("2017-01-10 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
endTime <- strptime("2017-05-05 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
timeList <- c(startTime)
while(startTime<endTime) {
    startTime <- startTime + (7*24*60*60)
    timeList <- c(timeList,startTime)
}

commits$week <- NA
for (j in 1:nrow(commits)) {
commits$week[j] <- (function(x,y) {
    n <- length(y)
    return <- NA
    for (i in 1:n-1) {
        if (x>=y[i] && x<y[i+1]) {
            return <- i
        }
    }
    return
}) (commits$created_at[j],timeList) }

commits$week <- as.factor(commits$week)
commits$created_by <- as.factor(commits$created_by)

# Plot graph of commits based on week
# for (team in unique(commits$team)) {
# 	team_data <- commits[commits$team==team,]
# 	plot(table(team_data[team_data$created_by=='user1',]$week),xlim=c(0,18),type="p",col="red")
# 	lines(table(team_data[team_data$created_by=='user2',]$week),xlim=c(0,18),type="p",col="green")
# 	lines(table(team_data[team_data$created_by=='user3',]$week),xlim=c(0,18),type="p",col="brown")
# 	if (is.element('user4',unique(team_data$created_by))==TRUE) {
# 		lines(table(team_data[team_data$created_by=='user4',]$week),xlim=c(0,18),type="p",col="black")
# 	}
# }

colRamp <- colorRampPalette(c("white", "black"))
plot(rep(1,length(timeList)),pch = 15,cex = 5,ylim=c(0,5),col=colRamp(length(timeList)))
points(rep(2,length(timeList)),pch = 15,cex = 5,col=colRamp(length(timeList)))

colRamp <- colorRampPalette(c("white", "black"))
plot(rep(1,length(timeList)),pch = 15,cex = 5,ylim=c(0.5,1.5),ylab="",xlab="Scale",col=colRamp(length(timeList)),yaxt='n',xaxt='n')

par(las=1)
colRamp <- colorRampPalette(c("white", "black"),interpolate = c("linear"))
for (team in unique(commits$team)) {
	team_data <- commits[commits$team==team,]
	x <- table(team_data$created_by,team_data$week)
	plot(rep(1,length(timeList)),pch = 15,cex = 5,ylim=c(0,5),col=colRamp(max(x)+1)[x[1,]+1],yaxt='n',main=paste("Color scale of number of commits per week : ",team),xlab="Week",ylab="")
	points(rep(2,length(timeList)), pch = 15,cex = 5, col=colRamp(max(x)+1)[x[2,]+1],yaxt='n')
	points(rep(3,length(timeList)), pch = 15,cex = 5, col=colRamp(max(x)+1)[x[3,]+1],yaxt='n')
	if (sum(x[4,]>0)) {
		points(rep(4,length(timeList)), pch = 15,cex = 5, col=colRamp(max(x)+1)[x[4,]+1],yaxt='n')
		axis(2,at=1:4,labels=c('user1','user2','user3','user4'))
	} else {
		axis(2,at=1:3,labels=c('user1','user2','user3'))
	}
}