#!/usr/bin/env python

"""
Python script to check for new CMSSW releases available in AFS space.
It is being run by acrontab every midnight
"""


import os
import xml.dom.minidom
from time import gmtime, strftime

print "I started: %s" % (strftime("%Y-%m-%d %H:%M:%S", gmtime()))
os.chdir("/home/DQMHisto")
reports_dir = os.listdir("report");
reports_to_do = []
if len(reports_dir) == 0:
   min_release = 'CMSSW_6_2_0_pre7'
else:
   min_release = min(reports_dir)

xml_data = xml.dom.minidom.parseString(os.popen("curl -s --insecure 'https://cmssdt.cern.ch/SDT/cgi-bin/ReleasesXML/?anytype=1'").read())
for arch in xml_data.documentElement.getElementsByTagName("architecture"):
    scram_arch = arch.getAttribute('name')
    print scram_arch
    for project in arch.getElementsByTagName("project"):
        release = str(project.getAttribute('label'))
        reports_to_do.append(release)

for elem in reports_to_do:
    if elem in reports_dir:
        print "%s report already exists" %(elem)
    else:
        #if elem.find('SLHC') != -1:
        if ((elem > min_release and elem != 'CMSSW_7_0_0_XROOTD')):
            #if elem == 'CMSSW_7_1_0_pre3': #test purposes only
            print "Report to do: %s" %(elem)
            os.system("./dqmHisto/test.sh "+ elem+"")
            print "Done!"
            break  #we work only on single release per day

##lets check the sequences reports
os.chdir("/home/DQMHisto")
reports_dir = os.listdir("DQMSequences");
existing_releases = []
for elem in reports_dir:
    tmp = elem.split("__")
    if len(tmp)>1:
        existing_releases.append(tmp[1])
existing_releases = list(set(existing_releases))

reports_to_do = []
if len(existing_releases) == 0:
   min_release = 'CMSSW_6_2_0_pre7'
else:
   min_release = min(existing_releases)

#xml_data = xml.dom.minidom.parseString(os.popen("curl -s --insecure 'https://cmstags.cern.ch/tc/ReleasesXML/?anytype=1").read())
for arch in xml_data.documentElement.getElementsByTagName("architecture"):
    scram_arch = arch.getAttribute('name')
    for project in arch.getElementsByTagName("project"):
        release = str(project.getAttribute('label'))
        reports_to_do.append((release, scram_arch))
for elem in reports_to_do:
    if elem[0] in existing_releases:
        print "SEQUENCES > %s report already exists" %(elem[0])
    else:
        if elem[0].find('SLHC') != -1:
            if (elem[0] > "CMSSW_6_2_0_SLHC7" and elem[0] != 'CMSSW_7_0_0_XROOTD'):
            #if elem == 'CMSSW_7_1_0_pre3': #test purposes only
                print "SEQUENCES > Report to do: %s arch %s" %(elem[0], elem[1])
                os.system("./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + " " + "auto:upgrade2019")
               # print "SEQUENCES > Done!"
               # break
        else:
            if ((elem[0] > min_release and elem[0] != 'CMSSW_7_0_0_XROOTD')):
                print "SEQUENCES > Report to do: %s arch %s" %(elem[0], elem[1])
                print "./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + "auto:mc"
                os.system("./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + " "+ "auto:mc")
                #print "SEQUENCES > Done!"
                #break
