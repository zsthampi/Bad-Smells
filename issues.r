require('plyr')


data = read.csv(file="issues.csv",head=TRUE,sep=",")
teams = unique(data$team)
totalUser = 0


#number of issue
numIssuesByTeam = vector()
for(i in 1:length(teams)){
  numIssuesByTeam[i] =  nrow(data[data[,"team"] == teams[[i]],])
}
avgIssueTeam = sum(numIssuesByTeam) / length(teams)
sdIssueTeam = sd(numIssuesByTeam)
medianIssueUser = median(numIssuesByTeam)

df = data.frame(teams,numIssuesByTeam)
df = df[order(df$numIssuesByTeam),]

plot = barplot(main="number of issues by team", df$numIssuesByTeam, names.arg=df$teams)
abline(h=avgIssueTeam, col = "blue")
abline(h=avgIssueTeam + sdIssueTeam, col = "red")
abline(h=avgIssueTeam - sdIssueTeam, col = "red")
abline(h=medianIssueUser, col = "green")
text(x = plot, y = df$numIssuesByTeam, label = df$numIssuesByTeam, pos = 1)

# add legend
legend_col <- c()
legend_col <- c(legend_col, "blue")
legend_col <- c(legend_col, "red")
legend_col <- c(legend_col, "green")

legend(0,100, c(sprintf("mean: %f",avgIssueTeam), 
                sprintf("standard deviation: %f",sdIssueTeam),
                sprintf("median: %f",medianIssueUser)
                ), 
       lty=c(1,1), lwd=c(2,2.5),col=legend_col)




#Issues assigned per user (should be evenly distributed)
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
        times[k] = times[k] + 1
      }
    }
  }
  if(times[4]==0){
    times = times[-4]
    totalUser = totalUser - 1
  }
  usersIssueVector = c(usersIssueVector, times)
  times = times/sum(times)
  issueAssignedList = c(issueAssignedList, list(times))
}



avgIssueUser = sum(numIssuesByTeam) / totalUser
sdIssueUser = sd(usersIssueVector)
medianIssueUser = median(usersIssueVector)










#Time taken per user to complete an issue
timeTakenList = list()
users = as.vector(c('user1','user2','user3','user4'))
tmpVector = vector()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  assignees = data[data[,"team"] == teams[[i]],]$assignees
  #users = unique(currTeamData$assignee)
  times = vector()
  for(k in 1:length(users)){
    if(users[k]==""||users[k]=="effat"||users[k]=="timm"){
      next
    }
    totalTime = 0
    issues = 0
    times[k] = 0
    for(j in 1:nrow(currTeamData)){
      if(grepl(users[k], assignees[[j]])){
        if(currTeamData[j,"closed_at"]!=""){
          strptime("2017-01-26T21:58:36Z",format="%Y-%m-%dT%H:%M:%SZ")
          created_at = strptime(currTeamData[j,"created_at"],format="%Y-%m-%dT%H:%M:%SZ")
          closed_at = strptime(currTeamData[j,"closed_at"],format="%Y-%m-%dT%H:%M:%SZ")
          totalTime = totalTime + difftime(closed_at, created_at, units = "hours")
          issues = issues + 1
        }
      }
    }
    times[k] = totalTime / issues
    if(k<4 && is.nan(times[k])){
      times[k] = 0
    }
  }
  if(is.nan(times[4])){
    times = times[-4]
  }
  timeTakenList = c(timeTakenList, list(round(times/24,1)))
  tmpVector = c(tmpVector, times)
}

avgTimeUser = sum(tmpVector) / totalUser
sdTimeUser = sd(tmpVector)
medianTimeUser = median(tmpVector)



#span of issues
issueSpan = vector()
due = vector()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  totalTime = 0
  issues = 0
  overdue = 0
  for(j in 1:nrow(currTeamData)){
      if(currTeamData[j,"closed_at"]!=""){
        strptime("2017-01-26T21:58:36Z",format="%Y-%m-%dT%H:%M:%SZ")
        created_at = strptime(currTeamData[j,"created_at"],format="%Y-%m-%dT%H:%M:%SZ")
        closed_at = strptime(currTeamData[j,"closed_at"],format="%Y-%m-%dT%H:%M:%SZ")
        if(currTeamData[j,"milestone_due_on"]!=""){
          milestone_due_on = strptime(currTeamData[j,"milestone_due_on"],format="%Y-%m-%dT%H:%M:%SZ")
          if((milestone_due_on > closed_at) == TRUE){
            overdue = overdue + 1
          }
        }
        totalTime = totalTime + difftime(closed_at, created_at, units = "hours")
        issues = issues + 1
      }
  }
  due[i] = overdue
  issueSpan[i] = totalTime / issues
}
#issue span by team
issueSpan = issueSpan/24
avgIssueSpan = sum(issueSpan)/length(teams)
sdIssueSpan = sd(issueSpan)
medianIssueSpan = median(issueSpan)
#issues close after due day
avgOverDue = mean(due)
sdOverDue = sd(due)
medianOverDue = median(due)
#percentage issues overdue
pct = round(due/numIssuesByTeam,2)
avgOverDue = mean(pct)
sdOverDue = sd(pct)
medianOverDue = median(pct)

df = data.frame(teams,issueSpan)
df = df[order(df$issueSpan),]
plot = barplot(main="Average length of issues by team in days", df$issueSpan, names.arg=df$teams)
abline(h=avgIssueSpan, col = "blue")
abline(h=avgIssueSpan-sdIssueSpan, col = "red")
abline(h=avgIssueSpan+sdIssueSpan, col = "red")
abline(h=medianIssueSpan, col = "green")
text(x = plot, y = round(df$issueSpan,1), label = round(df$issueSpan,1), pos = 1)
# add legend
legend_col <- c()
legend_col <- c(legend_col, "blue")
legend_col <- c(legend_col, "red")
legend_col <- c(legend_col, "green")
legend(0,25, c(sprintf("mean: %f",avgIssueSpan), 
               sprintf("standard deviation: %f",sdIssueSpan),
                sprintf("median: %f",medianIssueSpan)),
                
       lty=c(1,1), lwd=c(2,2.5),col=legend_col)




df = data.frame(teams,pct,due)
df = df[order(df$pct),]
plot = barplot(main="Percentage & number of overdued issues (if closed) by team", df$pct, names.arg=df$teams)
abline(h=avgOverDue, col = "blue")
abline(h=avgOverDue-sdOverDue, col = "red")
abline(h=avgOverDue+sdOverDue, col = "red")
abline(h=medianOverDue, col = "green")
text(x = plot, y = round(df$pct,2), label = round(df$pct,2), pos = 1)
text(x = plot, y = round(df$pct,2), label = df$due, pos = 3)

# add legend
legend_col <- c()
legend_col <- c(legend_col, "blue")
legend_col <- c(legend_col, "red")
legend_col <- c(legend_col, "green")
legend_col <- c(legend_col)
legend_col <- c(legend_col )
legend(0,0.7, c(sprintf("mean: %f",avgOverDue), 
                sprintf("standard deviation: %f",sdOverDue),
                sprintf("median: %f",medianOverDue)
                ,
                "text above: number of overdued issues",
                "text below: percentage of overdued issues"),
       lty=c(1,1), lwd=c(2,2.5),col=legend_col)







#number of comments
numComments = vector()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  numComments[i] = sum(currTeamData$comments)
}
meanComments = sum(numComments) / length(teams)
sdComments = sd(numComments)
medianComments = median(numComments)


df = data.frame(teams,numComments)
df = df[order(df$numComments),]

plot = barplot(main="Number of comments by team", df$numComments, names.arg=df$teams)
abline(h=meanComments, col = "blue")
abline(h=meanComments-sdComments, col = "red")
abline(h=meanComments+sdComments, col = "red")
abline(h=medianComments, col = "green")
text(x = plot, y = df$numComments, label = df$numComments, pos = 1)

# add legend
legend_col <- c()
legend_col <- c(legend_col, "blue")
legend_col <- c(legend_col, "red")
legend_col <- c(legend_col, "green")

legend(0,200, c(sprintf("mean: %f",meanComments), 
                sprintf("standard deviation: %f",sdComments),
                sprintf("median: %f",medianComments)
                ), 
       lty=c(1,1), lwd=c(2,2.5),col=legend_col)



