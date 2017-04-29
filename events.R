setwd('/Users/zubin/Documents/NCSU/Courses/CSC 510 - Software Engineering/Bad-Smells')
events <- read.csv('events.csv')

# Fix data 
typeof(events$team)
typeof(events$actor)
events$team <- as.character(events$team)
events$actor <- as.character(events$actor)
# Consider only events from users
events <- events[is.element(events$actor,c("user1","user2","user3","user4")),]
# Convert string to timezone
events$created_at <- strptime(as.character(events$created_at),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")

# Get the unique types of events
unique(events$type)

# Summary of events by team 
table(events$team)
barplot(sort(table(events$team)),ylim=c(0,500))

# Summary of events by team and user
# teams <- unique(events$team)
# n <- length(teams)
# close.screen(all.screens = TRUE)
# split.screen(c(3,4))
# for (i in 1:n) {
#     screen(i)
#     pie(table(events[events$team==teams[i],]$actor))
# }

# close.screen(all.screens = TRUE)

# Get numbers of events per week
startTime <- strptime("2017-01-10 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
endTime <- strptime("2017-05-05 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
timeList <- c(startTime)
while(startTime<endTime) {
    startTime <- startTime + (7*24*60*60)
    timeList <- c(timeList,startTime)
}

events$week <- NA
for (j in 1:nrow(events)) {
events$week[j] <- (function(x,y) {
    n <- length(y)
    return <- NA
    for (i in 1:n-1) {
        if (x>=y[i] && x<y[i+1]) {
            return <- i
        }
    }
    return
}) (events$created_at[j],timeList) }

events$week <- as.factor(events$week)
events$actor <- as.factor(events$actor)

# Plot graph of events based on week
# for (team in unique(events$team)) {
# 	team_data <- events[events$team==team,]
# 	plot(table(team_data[team_data$actor=='user1',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="red")
# 	lines(table(team_data[team_data$actor=='user2',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="green")
# 	lines(table(team_data[team_data$actor=='user3',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="brown")
# 	if (is.element('user4',unique(team_data$actor))==TRUE) {
# 		lines(table(team_data[team_data$actor=='user4',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="black")
# 	}
# }

par(las=1)
colRamp <- colorRampPalette(c("white", "black"),interpolate = c("linear"))
for (team in unique(events$team)) {
    team_data <- events[events$team==team,]
    x <- table(team_data$actor,team_data$week)
    plot(rep(1,length(timeList)),pch = 15,cex = 5,ylim=c(0,5),col=colRamp(max(x)+1)[x[1,]+1],yaxt='n',main=paste("Color scale of number of events per week : ",team),xlab="Week",ylab="")
    points(rep(2,length(timeList)), pch = 15,cex = 5, col=colRamp(max(x)+1)[x[2,]+1],yaxt='n')
    points(rep(3,length(timeList)), pch = 15,cex = 5, col=colRamp(max(x)+1)[x[3,]+1],yaxt='n')
    if (sum(x[4,]>0)) {
        points(rep(4,length(timeList)), pch = 15,cex = 5, col=colRamp(max(x)+1)[x[4,]+1],yaxt='n')
        axis(2,at=1:4,labels=c('user1','user2','user3','user4'))
    } else {
        axis(2,at=1:3,labels=c('user1','user2','user3'))
    }
}

