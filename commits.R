setwd('/Users/zubin/Documents/NCSU/Courses/CSC 510 - Software Engineering/Bad-Smells')
commits <- read.csv('commits.csv')

commits$created_at <- strptime(as.character(commits$created_at),format = "%Y-%m-%dT%H:%M:%SZ", tz="GMT")
commits$created_by <- as.character(commits$created_by)

commits_per_team <-  sort(table(commits$team))

# Barplot of number of commits per team
b <- barplot(commits_per_team,ylim=c(0,300),main="Total number of commits per team")
text(b,unname(commits_per_team),pos = 3)

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

barplot(x,legend.text = TRUE)

