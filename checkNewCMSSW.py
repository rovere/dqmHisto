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
   min_release = 'CMSSW_7_4_0_pre5'
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
        if elem.find('SLHC') != -1:
           continue ##we ignore SLHC releases for now
        if ((elem > min_release and elem != 'CMSSW_7_0_0_XROOTD')):
        #if elem == 'CMSSW_7_2_0_pre2': #test purposes only
            print "Report to do: %s" %(elem)
            #os.system("./dqmHisto/test.sh "+ elem+"")
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

#default min release
reports_to_do = []
if len(existing_releases) == 0:
   min_release = 'CMSSW_7_4_0_pre5'
else:
   min_release = min(existing_releases)

print "#DEBUG# min release: %s" % (min_release)
#xml_data = xml.dom.minidom.parseString(os.popen("curl -s --insecure 'https://cmstags.cern.ch/tc/ReleasesXML/?anytype=1").read())
for arch in xml_data.documentElement.getElementsByTagName("architecture"):
    scram_arch = arch.getAttribute('name')
    for project in arch.getElementsByTagName("project"):
        release = str(project.getAttribute('label'))
        reports_to_do.append((release, scram_arch))
for elem in reports_to_do:
    if elem[0] in existing_releases:
        #print "SEQUENCES > %s report already exists" %(elem[0])
        continue
    else:
        slhc_rel_list = [el for el in existing_releases if el.find('slhc') != -1]
        patch_rel_list = [el for el in existing_releases if el.find('patch') != -1]
        if elem[0].find('SLHC') != -1:
            continue
            if (elem[0] > "CMSSW_6_2_0_SLHC7" and elem[0] != 'CMSSW_7_0_0_XROOTD'):
            #if elem == 'CMSSW_7_1_0_pre3': #test purposes only
                print "SEQUENCES > SLHC report to do: %s arch %s" %(elem[0], elem[1])
                #os.system("./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + " " + "auto:upgrade2019") ##for now we dont need SLHC
               # print "SEQUENCES > Done!"
                #break
        elif elem[0].find('patch') != -1:
            if ((elem[0] > min(patch_rel_list) and elem[0] != 'CMSSW_7_0_0_XROOTD')):
                print "SEQUENCES > Patch report to do: %s arch %s" %(elem[0], elem[1])
                print "./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + "auto:mc"
                os.system("./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + " "+ "auto:mc")
                break ## we also want single sequence per day
        else:
            other_releases = set(existing_releases) - set(patch_rel_list) - set(slhc_rel_list)
            if ((elem[0] > min(other_releases) and elem[0] != 'CMSSW_7_0_0_XROOTD')):
            #if elem[0] == 'CMSSW_7_2_0_pre4': #test purposes only
                print "SEQUENCES > Report to do: %s arch %s" %(elem[0], elem[1])
                print "./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + "auto:mc"
                os.system("./dqmHisto/createHTMLSequences.sh "+elem[0]+" "+ elem[1] + " "+ "auto:mc")
                print "SEQUENCES > Done!"
                break ## we also want single sequence per day
