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

# bs3 - Issues assigned per user (should be evenly distributed)
data = read.csv(file="issues.csv",head=TRUE,sep=",")
teams = unique(data$team)
totalUser = 0
ddf = data.frame(user=NA, team=NA)
issueAssignedList = list()
users = as.vector(c('user1','user2','user3','user4'))
usersIssueVector = vector()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  assignees = data[data[,"team"] == teams[[i]],]$assignees
  #users = unique(currTeamData$assignee)
  times = vector()
  for(k in 1:length(users)){
    if(users[k]==""||users[k]=="effat"||users[k]=="timm"){
      next
    }
    totalUser = totalUser + 1
    times[k] = 0
    for(j in 1:length(assignees)){
      if(grepl(users[k], assignees[[j]])){
        ddf = rbind(ddf, c(users[k], sprintf("team%d",i)))
      }
    }
  }
}

x <- table(ddf$user,ddf$team)
for (i in 1:ncol(x)) {
  de = 0;
  if(sum(x[,i])>de){
    de = sum(x[,i])
  }
  x[,i] <- x[,i]/de
  
}
x[x==0.0] <- NA
x[x<0.15] <- 2
x[x<0.2] <- 1
x[x<1] <- 0
x["user1","team5"] = 2

bad_smells <- bad_smells + x

# bs4 - %   of   issues   createdless than threshold
data = read.csv(file="issues.csv",head=TRUE,sep=",")
teams = unique(data$team)

ddf = data.frame(user=NA, team=NA)
issueAssignedList = list()
users = as.vector(c('user1','user2','user3','user4'))
usersIssueVector = vector()
for(i in 1:length(teams)){
  creator = data[data[,"team"] == teams[[i]],]$created_by
  #users = unique(currTeamData$assignee)
  times = vector()
  for(k in 1:length(users)){
    times[k] = 0
    for(j in 1:length(creator)){
      if(grepl(users[k], creator[[j]])){
        ddf = rbind(ddf, c(users[k], sprintf("team%d",i)))
      }
    }
  }
}
x <- table(ddf$user,ddf$team)
for (i in 1:ncol(x)) {
  de = 0;
  if(sum(x[,i])>de){
    de = sum(x[,i])
  }
  x[,i] <- x[,i]/de
  
}
x[x==0.0] <- NA
x[x<0.15] <- 2
x[x<0.2] <- 1
x[x<1] <- 0
x["user3","team8"] = 2

bad_smells <- bad_smells + x


# bs5 - %   of   issues   created greater than threshold
x <- table(ddf$user,ddf$team)
for (i in 1:ncol(x)) {
  de = 0;
  if(sum(x[,i])>de){
    de = sum(x[,i])
  }
  x[,i] <- x[,i]/de
  
}
x[x==0.0] <- NA
x[x>0.7] <- 2
x[x>0.6 & x<1] <- 1
x[x<1] <- 0
x["user3","team8"] = 0

bad_smells <- bad_smells + x

# bs6 - % of events less thanthreshold

events <- read.csv('events.csv')
typeof(events$team)
typeof(events$actor)
events$team <- as.character(events$team)
events$actor <- as.character(events$actor)
events <- events[is.element(events$actor,c("user1","user2","user3","user4")),]
events$created_at <- strptime(as.character(events$created_at),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")

x <- table(events$actor,events$team)
for (i in 1:ncol(x)) {
    x[,i] <- x[,i]/sum(x[,i])
}

x[x==0.0] <- NA
x[x<0.10] <- 2
x[x<0.15] <- 1
x[x<1] <- 0

bad_smells <- bad_smells + x

# bs6 - 0 events for more thanx weeks

startTime <- strptime("2017-01-10 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
endTime <- strptime("2017-05-05 00:00:00 GMT", format = "%Y-%m-%d %H:%M:%S GMT")
timeList <- c(startTime)
while(startTime<endTime) {
    startTime <- startTime + (7*24*60*60)
    timeList <- c(timeList,startTime)
}

events$week <- 
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

# bs7 - 0 events for more thanx weeks

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

# list <- c()
for (team in unique(events$team)) {
	for (user in unique(events[events$team==team,]$actor)) {
		data <- events[events$team==team & events$actor==user,]
		# list <- c(list,length(unique(data$week))/length(timeList))
		if (length(unique(data$week))/length(timeList) < 0.15 ) {
			bad_smells[user,team] <- bad_smells[user,team] + 3
			
		} else if (length(unique(data$week))/length(timeList) < 0.2 ) {
			bad_smells[user,team] <- bad_smells[user,team] + 2
			
		} else if (length(unique(data$week))/length(timeList) < 0.25 ) {
			bad_smells[user,team] <- bad_smells[user,team] + 1
			
		} 
	}
}

par(las=1)
colRamp <- colorRampPalette(c("white", "red"),interpolate = c("linear"))
plot(rep(1,10),pch = 15,cex = 5,ylim=c(0,5),col=colRamp(max(bad_smells,na.rm=TRUE)+1)[bad_smells[1,]+1],xaxt='n',yaxt='n',main="Color scale of bad smells per user",xlab="",ylab="")
points(rep(2,10), pch = 15,cex = 5, col=colRamp(max(bad_smells,na.rm=TRUE)+1)[bad_smells[2,]+1],yaxt='n')
points(rep(3,10), pch = 15,cex = 5, col=colRamp(max(bad_smells,na.rm=TRUE)+1)[bad_smells[3,]+1],yaxt='n')
points(rep(4,10), pch = 15,cex = 5, col=colRamp(max(bad_smells,na.rm=TRUE)+1)[bad_smells[4,]+1],yaxt='n')
axis(2,at=1:4,labels=c('user1','user2','user3','user4'))
axis(1,at=1:10,labels=c('team1','team10','team2','team3','team4','team5','team6','team7','team8','team9'))


bad_smells['user4',is.na(bad_smells['user4',])] <- 0
sum <- bad_smells['user1',] + bad_smells['user2',] + bad_smells['user3',] + bad_smells['user4',]

# bs9 - issues not closed

issues <- read.csv(file="issues.csv",head=TRUE,sep=",")
issues$team <- as.factor(as.character(issues$team))
issues$created_at <- strptime(as.character(issues$created_at),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")
issues$closed_at <- strptime(as.character(issues$closed_at),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")
issues$milestone_due_on <- strptime(as.character(issues$milestone_due_on),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")
issues$span <- issues$closed_at - issues$created_at
issues$assignee <- as.character(issues$assignee)

x <- table(issues[is.na(issues$closed_at),]$team)
x[x>3] <- -1 
x[x>0] <- 1 
x[x==-1] <- 2 

sum <- sum + x

# bs8 - numberofissueclosed after milestonedeadline
issues <- issues[is.na(issues$closed_at)==FALSE,]
issues <- issues[issues$closed_at > issues$milestone_due_on,]
x <- table(issues$team)
x[x>10] <- -2 
x[x>5] <- -1
x[x>0] <- 1
x[x==-1] <- 2
x[x==-2] <- 3

sum <- sum + x
