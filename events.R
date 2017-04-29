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

# Summary of events by team and user
teams <- unique(events$team)
n <- length(teams)
close.screen(all.screens = TRUE)
split.screen(c(3,4))
for (i in 1:n) {
    screen(i)
    pie(table(events[events$team==teams[i],]$actor))
}

close.screen(all.screens = TRUE)

# Get numbers of events per week
startTime <- strptime("2017-01-19 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
endTime <- strptime("2017-04-22 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
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

# Plot graph of events based on week
for (team in unique(events$team)) {
	team_data <- events[events$team==team,]
	plot(table(team_data[team_data$actor=='user1',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="red")
	lines(table(team_data[team_data$actor=='user2',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="green")
	lines(table(team_data[team_data$actor=='user3',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="brown")
	if (is.element('user4',unique(team_data$actor))==TRUE) {
		lines(table(team_data[team_data$actor=='user4',]$week),xlim=c(0,15),ylim=c(0,50),type="l",col="black")
	}
}

