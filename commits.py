#  gitabel
#  the world's smallest project management tool
#  reports relabelling times in github (time in seconds since epoch)
#  thanks to dr parnin
#  todo:
#    - ensure events sorted by time
#    - add issue id
#    - add person handle

"""
You will need to add your authorization token in the code.
Here is how you do it.

1) In terminal run the following command

curl -i -u <your_username> -d '{"scopes": ["repo", "user"], "note": "OpenSciences"}' https://api.github.com/authorizations

2) Enter ur password on prompt. You will get a JSON response. 
In that response there will be a key called "token" . 
Copy the value for that key and paste it on line marked "token" in the attached source code. 

3) Run the python file. 

     python gitable.py

"""
 
from __future__ import print_function
import urllib2
import json
import re,datetime
import sys
import numpy as np
import pandas as pd
data = []
team = None
users = {'team8': {'sshankjha': 'user2','Shashank Jha': 'user2', 'jdeng8': 'user4', 'bhaskarsinha1311': 'user3', 'Bhaskar Sinha': 'user3', 'effat': 'effat', 'MichaelGoff': 'user1', 'timm': 'timm'}, 'team9': {'mohits19': 'user1', 'SidHeg': 'user2', 'effat': 'effat', 'saravanan19': 'user3', 'sbalasu7': 'user3', 'timm': 'timm'}, 'team4': {'adrianluan': 'user3', 'zsthampi': 'user1', 'effat': 'effat', 'fuzailm1': 'user2', 'timm': 'timm'}, 'team5': {'bhushan9': 'user1', 'ZacheryThomas': 'user2', 'effat': 'effat', 'rnambis': 'user3', 'timm': 'timm'}, 'team6': {'mfarve1': 'user3', 'effat': 'effat', 'ChristineTzeng': 'user2', 'genterist': 'user1', 'genterist2': 'user4', 'timm': 'timm'}, 'team7': {'harshalgala': 'user2', 'qiufengyu21': 'user1', 'effat': 'effat', 'gosavipooja': 'user3', 'pigosavi': 'user3', 'timm': 'timm'}, 'team1': {'karanjadhav2508': 'user1','Karan Jadhav': 'user1', 'effat': 'effat', 'alokozai': 'user2', 'smscoggi': 'user3', 'timm': 'timm'}, 'team2': {'thegreyd': 'user1', 'DevArenaCN': 'user3', 'effat': 'effat', 'KaustubhG': 'user2', 'timm': 'timm'}, 'team3': {'popoosl': 'user3', 'effat': 'effat', 'Rushi-Bhatt': 'user1', 'dndesai': 'user2', 'timm': 'timm','czhao13rm':'user4','Chen':'user4'}, 'team10': {'Sanand007': 'user4', 'effat': 'effat', 'ecdraayer': 'user1', 'syazdan25': 'user2', 'timm': 'timm', 'MahnazBehroozi': 'user3'}}

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
 
def dump1(u,repo):
  token = "" # <===
  request = urllib2.Request(u, headers={"Authorization" : "token "+token})
  v = urllib2.urlopen(request).read()
  w = json.loads(v)
  for sha in [row['commit']['sha'] for row in w if row['name']=='master']:
    launchDump2(repo,sha)


def dump2(u):
  global data
  global team
  token = "" # <===
  request = urllib2.Request(u, headers={"Authorization" : "token "+token})
  v = urllib2.urlopen(request).read()
  w = json.loads(v)
  if not w: return False
  for commit in w:
    commits_data = {}
    commits_data['team'] = team
    if commit['author']:
      commits_data['created_by'] = users[team][str(commit['author']['login'])]
    else:
      commits_data['created_by'] = users[team][str(commit['commit']['author']['name'])]
    commits_data['created_at'] = commit['commit']['author']['date']
    commits_data['message'] = commit['commit']['message']
    data.append(commits_data)

  return True

def launchDump(repo):
  page = 1
  while(True):
    doNext = dump1('https://api.github.com/repos/'+repo+'/branches?page=' + str(page),repo)
    print("page "+ str(page))
    page += 1
    if not doNext : break

def launchDump2(repo,sha):
  page = 1
  while(True):
    doNext = dump2('https://api.github.com/repos/'+repo+'/commits?sha='+sha+'&page=' + str(page))
    print("page "+ str(page))
    page += 1
    if not doNext : break

start = [('team1',['karanjadhav2508/kqsse17']),
('team2',['SE17GroupH/Zap','SE17GroupH/ZapServer']),
('team3',['Rushi-Bhatt/SE17-Team-K']),
('team4',['zsthampi/SE17-Group-N']),
('team5',['rnambis/SE17-group-O']),
('team6',['genterist/whiteWolf']),
('team7',['harshalgala/se17-Q']),
('team8',['NCSU-SE-Spring-17/SE-17-S']),
('team9',['SidHeg/se17-teamD']),
('team10',['syazdan25/SE17-Project'])]

for team,repos in start:
  print (team)
  for repo in repos:
    launchDump(repo)

df = pd.DataFrame(data)
df.to_csv('commits.csv',sep=',',index=False,encoding='utf-8')
   
 