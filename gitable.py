from __future__ import print_function
import urllib2
import json
import re,datetime
import sys
import pandas as pd
import json

df=pd.DataFrame()
rowsList = []
final = dict()
class L():
  "Anonymous container"
  def __init__(i,**fields) : 
    i.override(fields)
  def override(i,d): i.__dict__.update(d); return i
  def __repr__(i):
    d = i.__dict__
    name = i.__class__.__name__
    return name+'{'+' '.join([':%s %s' % (k,pretty(d[k])) 
                     for k in i.show()])+ '}'
  def show(i):
    lst = [str(k)+" : "+str(v) for k,v in i.__dict__.iteritems() if v != None]
    return ',\t'.join(map(str,lst))

  
def secs(d0):
  d     = datetime.datetime(*map(int, re.split('[^\d]', d0)[:-1]))
  epoch = datetime.datetime.utcfromtimestamp(0)
  delta = d - epoch
  return delta.total_seconds()
 
def dump1(u,issues):
  token = "153106e32d628b1e1d48e82f34a5e7600c125845" # <===
  request = urllib2.Request(u, headers={"Authorization" : "token "+token})
  v = urllib2.urlopen(request).read()
  w = json.loads(v)

  d={}
  # with open('teamo.json', 'w') as outfile:
  #   json.dumps(w, outfile)
  
  
  if not w: return False

  k=0
  for event in w:
    k +=1
    print(k)

    issue_id = event['issue']['number']
    event_created_at = secs(event['created_at'])
    action = event['event']
    user = event['actor']['login']
    milestone = event['issue']['milestone']
    try:
      issue_created_at = secs(event["issue"]["created_at"])
    except:
      issue_created_at = None
    try:
      issue_closed_at = secs(event["issue"]["closed_at"])
    except:
      issue_closed_at = None
    labels= event['issue']['labels']
    labels_name=[]
    labels_color=[]
    for label in labels:
      labels_name.append(label['name'])
      labels_color.append(label['color'])


    
    comments = event['issue']['comments']
    #print(event[])
    if event['issue']['assignee'] is not None:
      assignee = event['issue']['assignee']['login']
    else:
      assignee=[]
    
    assignees_name=[]
    
    assignees = event['issue']['assignees']
    for each in assignees:
      assignees_name.append(each['login'])
    #body = event['issue']['body']
    title = event['issue']['title']
    
    milestone_created_at = 'None'
    milestone_due_on = 'None'
    milestone_closed_at = 'None'
    mclose_created='None'
    mdue_created='None'
    if milestone != None :
      milestone = milestone['title']
      milestone_created_at = secs(event["issue"]["milestone"]["created_at"])
      milestone_closed_at = event["issue"]["milestone"]["closed_at"]
      if not milestone_closed_at:
        milestone_closed_at = 'None'
      else:
        milestone_closed_at = secs(event["issue"]["milestone"]["closed_at"])
        mclose_created = milestone_closed_at - milestone_created_at
      try:
        milestone_due_on = secs(event["issue"]["milestone"]["due_on"])
      except:
        milestone_due_on = None
      try:
        mdue_created = milestone_due_on - milestone_created_at
      except:
        mdue_created = None
    else:
     milestone = 'None'



    eventObj = L(event_created_at=event_created_at,
                 action = action,
                 user = user,
                 milestone = milestone,
                 comments=comments,
                 assignee = assignee,
                 assignees_name = assignees_name,
                 labels_name = labels_name,
                 labels_color = labels_color,
                 issue_id = issue_id,
                 issue_created_at= issue_created_at,
                 issue_closed_at = issue_closed_at,
                 milestone_due_on = milestone_due_on,
                 milestone_closed_at = milestone_closed_at,
                 milestone_created_at = milestone_created_at,
                 #body=body,
                 title=title
                 )
  

    d['event_created_at']=event_created_at
    d['action']=action
    d['user']=user
    d['milestone']=milestone
    d['comments']=comments
    d['assignee']=assignee
    d['assignees_name']=assignees_name
    d['labels_name']=labels_name
    d['labels_color']=labels_color
    d['title']=title
    d['issue_id']=issue_id
    d['issue_created_at']= issue_created_at
    d['issue_closed_at'] = issue_closed_at
    d['milestone_created_at'] = milestone_created_at
    d['milestone_closed_at'] = milestone_closed_at
    d['milestone_due_on'] = milestone_due_on
    d['mclose_created']=mclose_created
    d['mdue_created'] = mdue_created

    #print(d['title'])

    all_events = issues.get(issue_id)
    if not all_events: 
      all_events = []
      
    all_events.append(eventObj)
    rowsList.append(d)
    d={}
    final[issue_id]=rowsList
    issues[issue_id] = all_events
  return True

def dump(u,issues):
  return dump1(u, issues)

def launchDump(repo):
  page = 1
  issues = dict()
  while(True):
    doNext = dump('https://api.github.com/repos/'+repo+'/issues/events?page=' + str(page), issues)
    print("page "+ str(page))
    page += 1
    if not doNext : break

  count = 0
  # for issue, events in issues.iteritems():
  #   print("ISSUE " + str(issue))
  #   for event in events: 
  #     print(event.show())
  #     count +=1
  #   print('')

  #print(count)




 
  # with open('result.json', 'w') as fp:
  #   json.dump(issues, fp)
repos = ['karanjadhav2508/kqsse17',
      'SE17GroupH/Zap', 
      'SE17GroupH/ZapServer',
      'Rushi-Bhatt/SE17-Team-K',
      'zsthampi/SE17-Group-N', 
      'rnambis/SE17-group-O', 
      'genterist/whiteWolf', 
      'harshalgala/se17-Q', 
      'NCSU-SE-Spring-17/SE-17-S', 
      'SidHeg/se17-teamD', 
      'syazdan25/SE17-Project'
      ]

for index,repo in enumerate(repos):
  rowsList = []
  launchDump(repo)
  # print(type(rowsList))

  # for each in rowsList:
  #   print(each['title'])
  #   print("\n")

  df=pd.DataFrame(rowsList)
  df.to_csv('team'+str(index)+'.csv',sep=',')

