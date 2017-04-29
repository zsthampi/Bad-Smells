require('plyr')


data = read.csv(file="milestones.csv",head=TRUE,sep=",")
teams = unique(data$team)

#milestones number
milestoneByTeam = vector()
for(i in 1:length(teams)){
  milestoneByTeam[i] =  nrow(data[data[,"team"] == teams[[i]],])
}
averageMileStone = sum(milestoneByTeam)/length(teams)
sdMileStone = sd(milestoneByTeam)
medianMileStone = median(milestoneByTeam)

df = data.frame(teams,milestoneByTeam)
df = df[order(df$milestoneByTeam),]
plot = barplot(main="Number of milestones by team", df$milestoneByTeam, names.arg=df$teams)
abline(h=averageMileStone, col = "blue")
abline(h=averageMileStone-sdMileStone, col = "red")
abline(h=averageMileStone+sdMileStone, col = "red")
abline(h=medianMileStone, col = "green")
text(x = plot, y = df$milestoneByTeam, label = df$milestoneByTeam, pos = 1)

# add legend
legend_col <- c()
legend_col <- c(legend_col, "blue")
legend_col <- c(legend_col, "red")
legend_col <- c(legend_col, "green")

legend(0,10, c(sprintf("mean: %f",averageMileStone), 
               sprintf("standard deviation: %f",sdMileStone),
                sprintf("median: %f",medianMileStone)
                ), 
       lty=c(1,1), lwd=c(2,2.5),col=legend_col)











#milestones span
#msTime, a vector of average hours a milestone(if closed)
#due, a vector of the number of milestone closed after due
#noclose, a vector of the number of milestone not closed
msTime = vector()
due = vector()
noclose = vector()
counts = vector()
for(i in 1:length(teams)){
  currTeamData = data[data[,"team"] == teams[[i]],]
  totalTime = 0
  count = 0
  overdue = 0
  due[i] = 0
  noclose[i] = 0
  for(j in 1:nrow(currTeamData)){
    if(currTeamData[j,"closed_at"]!=""){
      strptime("2017-01-26T21:58:36Z",format="%Y-%m-%dT%H:%M:%SZ")
      created_at = strptime(currTeamData[j,"created_at"],format="%Y-%m-%dT%H:%M:%SZ")
      closed_at = strptime(currTeamData[j,"closed_at"],format="%Y-%m-%dT%H:%M:%SZ")
      if(currTeamData[j,"due_on"]!=""){
        milestone_due_on = strptime(currTeamData[j,"due_on"],format="%Y-%m-%dT%H:%M:%SZ")
        if((milestone_due_on > closed_at) == TRUE){
          overdue = overdue + 1
        }
      }
      totalTime = totalTime + difftime(closed_at, created_at, units = "hours")
      count = count + 1
    }else{
      noclose[i] = noclose[i] + 1
    }
  }
  due[i] = overdue
  if(count==0){
    msTime[i] = 0
    counts[i] = 0
  }else{
    msTime[i] = totalTime / count
    counts[i] = count
  }
}
msTime = msTime/24
tmp = msTime
tmp = tmp[-1]
tmp = tmp[-2]
avgMilestoneTime = mean(tmp)
sdMileStoneTime = sd(tmp)
medianMileStoneTime = median(tmp)


df = data.frame(teams,msTime)
df = df[order(df$msTime),]
plot = barplot(main="Average length of milestones by team in days", df$msTime, names.arg=df$teams)
abline(h=avgMilestoneTime, col = "blue")
abline(h=avgMilestoneTime+sdMileStoneTime, col = "red")
abline(h=avgMilestoneTime-sdMileStoneTime, col = "red")
abline(h=medianMileStoneTime, col = "green")
text(x = plot, y = df$msTime, label = round(df$msTime), pos = 1)

# add legend
legend_col <- c()
legend_col <- c(legend_col, "blue")
legend_col <- c(legend_col, "red")
legend_col <- c(legend_col, "green")

legend(0,60, c(sprintf("mean: %f",avgMilestoneTime), 
                 sprintf("standard deviation: %f",sdMileStoneTime),
               sprintf("median: %f",medianMileStoneTime),
               "0 means no milestone is closed"), 
       lty=c(1,1), lwd=c(2,2.5),col=legend_col)




