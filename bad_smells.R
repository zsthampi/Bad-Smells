setwd('/Users/zubin/Documents/NCSU/Courses/CSC 510 - Software Engineering/Bad-Smells')

# bs1 - % commits
commits <- read.csv('commits.csv')
commits$created_at <- strptime(as.character(commits$created_at),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")
commits$created_by <- as.character(commits$created_by)
x <- table(commits$created_by,commits$team)
for (i in 1:ncol(x)) {
    x[,i] <- x[,i]/sum(x[,i])
}
x[x==0.0] <- NA
x[x<0.10] <- 2
x[x<0.15] <- 1
x[x<1] <- 0

bad_smells <- x

# bs2 - 0 commits for more than x weeks

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

for (team in unique(commits$team)) {
	for (user in unique(commits[commits$team==team,]$created_by)) {
		data <- commits[commits$team==team & commits$created_by==user,]
		if (length(unique(data$week))/length(timeList) < 0.15 ) {
			bad_smells[user,team] <- bad_smells[user,team] + 3
			
		} else if (length(unique(data$week))/length(timeList) < 0.2 ) {
			bad_smells[user,team] <- bad_smells[user,team] + 2
			
		} else if (length(unique(data$week))/length(timeList) < 0.25 ) {
			bad_smells[user,team] <- bad_smells[user,team] + 1
			
		} 
	}
}

