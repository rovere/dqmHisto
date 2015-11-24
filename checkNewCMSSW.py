#!/usr/bin/env python

"""
Python script to check for new CMSSW releases available in AFS space.
It is being run by acrontab every midnight
"""


import os
import re
import xml.dom.minidom

from time import gmtime, strftime

def nat_cmp(a, b):
    """
    compares two alphanumeric string in "natural" way retruns 1 if a > b else -1
    """

    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return cmp(alphanum_key(a), alphanum_key(b))

print "I started: %s" % (strftime("%Y-%m-%d %H:%M:%S", gmtime()))
os.chdir("/home/DQMHisto")
reports_dir = os.listdir("report");
reports_to_do = []
if len(reports_dir) == 0:
   min_release = 'CMSSW_7_4_0_pre5'
else:
   min_release = min(reports_dir)
patch_rel_list = [el for el in reports_dir if el.find('patch') != -1]
print "##DEBUG Min patch release: ", min(patch_rel_list)

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
        elif elem.find('patch') != -1:
            if nat_cmp(elem, min(patch_rel_list)) == 1:
                print "Report to do: %s patch min_rel %s" %(elem, min(patch_rel_list))
                os.system("./dqmHisto/test.sh "+ elem+"")
                print "Done!"
                break  #we work only on single release per day
        elif nat_cmp(elem, min_release) == 1:
        #if elem == 'CMSSW_7_2_0_pre2': #test purposes only
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

#default min release
reports_to_do = []
if len(existing_releases) == 0:
   min_release = 'CMSSW_7_4_0_pre5'
else:
   min_release = min(existing_releases)

print "#DEBUG# min release: %s" % (min_release)
for arch in xml_data.documentElement.getElementsByTagName("architecture"):
    scram_arch = arch.getAttribute('name')
    for project in arch.getElementsByTagName("project"):
        release = str(project.getAttribute('label'))
        reports_to_do.append((release, scram_arch))

slhc_rel_list = [el for el in existing_releases if el.find('slhc') != -1]
patch_rel_list = [el for el in existing_releases if el.find('patch') != -1]
for elem in reports_to_do:
    if elem[0] in existing_releases:
        continue
    else:
        if elem[0].find('SLHC') != -1:
            continue
        elif elem[0].find('patch') != -1:
            if nat_cmp(elem[0], min(patch_rel_list)) == 1:
                print "SEQUENCES > Patch report to do: %s arch %s" % (elem[0], elem[1])
                print "./dqmHisto/createHTMLSequences.sh " + elem[0] + " " +\
                        elem[1] + "auto:mc"

                os.system("./dqmHisto/createHTMLSequences.sh " + elem[0] + " " +\
                        elem[1] + " "+ "auto:mc")

                break ## we also want single sequence per day
        else:
            other_releases = set(existing_releases) - set(patch_rel_list) -\
                set(slhc_rel_list)

            if nat_cmp(elem[0], min(other_releases)) == 1:
            #if elem[0] == 'CMSSW_7_2_0_pre4': #test purposes only
                print "SEQUENCES > Report to do: %s arch %s" % (elem[0], elem[1])
                print "./dqmHisto/createHTMLSequences.sh " + elem[0] + " " +\
                        elem[1] + "auto:mc"

                os.system("./dqmHisto/createHTMLSequences.sh " + elem[0] + " " +\
                        elem[1] + " "+ "auto:mc")

                print "SEQUENCES > Done!"
                break ## we also want single sequence per day
