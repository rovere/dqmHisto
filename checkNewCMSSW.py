#!/usr/bin/env python

"""
Python script to check for new CMSSW releases available in AFS space.
It is being run by acrontab every midnight
"""


import os
import xml.dom.minidom

os.chdir("/home/DQMHisto")
reports_dir = os.listdir("report");
reports_to_do = []
if len(reports_dir) == 0:
   min_release = 'CMSSW_6_2_0_pre7'
else:
   min_release = min(reports_dir)

xml_data = xml.dom.minidom.parseString(os.popen("curl -s --insecure 'https://cmstags.cern.ch/tc/ReleasesXML/?anytype=1'").read())
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
        if elem > min_release:
            print "Report to do: %s" %(elem)
            os.system("./dqmHisto/test.sh "+ elem+"")
            print "Done!"

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
    print scram_arch
    for project in arch.getElementsByTagName("project"):
        release = str(project.getAttribute('label'))
        reports_to_do.append(release)

print "##: %s"%(existing_releases)
for elem in reports_to_do:
    if elem in existing_releases:
        print "SEQUENCES > %s report already exists" %(elem)
    else:
        if elem > min_release:
            print "SEQUENCES > Report to do: %s" %(elem)
            print "SEQUENCES > %s" %(os.getcwd())
            os.system("./dqmHisto/createHTMLSequences.sh "+elem+"")
            print "SEQUENCES > Done!"
