require('plyr')


data = read.csv(file="issues.csv",head=TRUE,sep=",")
teams = unique(data$team)


#Issues assigned per user (should be evenly distributed)
issueAssignedList = list()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  assignees = data[data[,"team"] == teams[[i]],]$assignees
  users = unique(currTeamData$assignee)
  times = vector()
  n = 1
  for(k in 1:length(users)){
    if(users[k]==""||users[k]=="effat"||users[k]=="timm"){
      next
    }
    times[n] = 0
    for(j in 1:length(assignees)){
      if(grepl(users[k], assignees[[j]])){
        times[n] = times[n] + 1
      }
    }
    n = n + 1
  }
  issueAssignedList = c(issueAssignedList, list(times))
}


#Time taken per user to complete an issue
timeTakenList = list()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  #assignees = data[data[,"team"] == teams[[i]],]$assignees
  users = unique(currTeamData$assignee)
  times = vector()
  n = 1
  
  for(k in 1:length(users)){
    if(users[k]==""||users[k]=="effat"||users[k]=="timm"){
      next
    }
    totalTime = 0
    issues = 0
    for(j in 1:nrow(currTeamData)){
      if(currTeamData[j,"closed_at"]!=""){
        strptime("2017-01-26T21:58:36Z",format="%Y-%m-%dT%H:%M:%SZ")
        created_at = strptime(currTeamData[j,"created_at"],format="%Y-%m-%dT%H:%M:%SZ")
        closed_at = strptime(currTeamData[j,"closed_at"],format="%Y-%m-%dT%H:%M:%SZ")
        print(difftime(closed_at, created_at, units = "hours"))
        totalTime = totalTime + difftime(closed_at, created_at, units = "hours")
        issues = issues + 1
      }
    }
    times[n] = totalTime / issues
    n = n + 1
  }
  timeTakenList = c(timeTakenList, list(times))
}


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


#number of issue
numIssues = vector()
for(i in 1:length(teams)){
  numIssues[i] =  nrow(data[data[,"team"] == teams[[i]],])
}


#number of comments
numComments = vector()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  numComments[i] = sum(currTeamData$comments)
}



