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

xml_data = xml.dom.minidom.parseString(os.popen("curl -s --insecure 'https://cmstags.cern.ch/tc/ReleasesXML/?anytype=1&architecture=slc5_amd64_gcc472'").read())
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
        
