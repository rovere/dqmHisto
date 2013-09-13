#!/bin/bash

createRelease()
{
    #cd /build/rovere/dqmOfflineSequences
    cd dqmOfflineSequences
    scram p "$RELEASE"

    if [ $? -eq 0 ]; then
      cd ${RELEASE}/src
      cp /home/DQMHisto/dqmHisto/py2html_new.py .
      eval `scram runtime -sh`
      return 1
    fi

    return 0
}
removeRelease()
{
    cd ../..
    ls -lh
    echo "Lets remove release from working space: $RELEASE"
    rm -rf $RELEASE
}

createSequences()
{
    cmsDriver.py step2_DQM -s RECO,DQM -n 10 --eventcontent DQM --conditions auto:com10  --filein  file:/afs/cern.ch/cms/CAF/CMSCOMM/COMM_DQM/DQMTest/MinimumBias__RAW__v1__165633__1CC420EE-B686-E011-A788-0030487CD6E8.root --data --no_exec --scenario ${SCENARIO}
    #python step2_DQM_RECO_DQM.py
#    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_DQM.gz cmsRun step2_DQM_RECO_DQM.py
#    igprof-analyse -g -d -v -p -r MEM_LIVE -s step2_DQM_RECO_DQM.gz | sqlite3 step2_DQM_RECO_DQM_LIVE.sql3
    #igprof-analyse -g -d -v -p -r MEM_TOT -s step2_DQM_RECO_DQM.gz | sqlite3 step2_DQM_RECO_DQM_TOT.sql3
    #igprof-analyse -g -d -v -p -r MEM_LIVE -s ${SCENARIO}_1.gz | sqlite3 igreport_MEMLIVE_
    #./py2html_new.py step2_DQM_RECO_DQM.py >/dev/null
    ./py2html_new.py step2_DQM_RECO_DQM.py step2_DQM_RECO_DQM_LIVE.sql3
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_DQM -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}/step2/html/index.html\" >${RELEASE} - Step2 - DQM </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    cmsDriver.py step2_DQM -s RECO,VALIDATION -n 10 --eventcontent DQM --filein  file:/afs/cern.ch/cms/CAF/CMSCOMM/COMM_DQM/DQMTest/MinimumBias__RAW__v1__165633__1CC420EE-B686-E011-A788-0030487CD6E8.root --conditions auto:mc  --mc --no_exec --scenario ${SCENARIO}
    #python step2_DQM_RECO_VALIDATION.py
#    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz cmsRun step2_DQM_RECO_VALIDATION.py
#    igprof-analyse -g -d -v -p -r MEM_LIVE -s step2_DQM_RECO_VALIDATION.gz | sqlite3 step2_DQM_RECO_VALIDATION_LIVE.sql3
    #igprof-analyse -g -d -v -p -r MEM_TOT -s step2_DQM_RECO_VALIDATION.gz | sqlite3 step2_DQM_RECO_VALIDATION_TOT.sql3
    #./py2html_new.py step2_DQM_RECO_VALIDATION.py >/dev/null
    ./py2html_new.py step2_DQM_RECO_VALIDATION.py step2_DQM_RECO_VALIDATION_LIVE.sql3
    if [ $? -ne 0 ]; then
        return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__val/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__val/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VAL -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__val/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    cmsDriver.py step2_DQM -s RECO,VALIDATION:validation_preprod -n 10 --eventcontent DQM  --filein  file:/afs/cern.ch/cms/CAF/CMSCOMM/COMM_DQM/DQMTest/MinimumBias__RAW__v1__165633__1CC420EE-B686-E011-A788-0030487CD6E8.root --conditions auto:mc  --mc --no_exec --scenario ${SCENARIO}
    #python step2_DQM_RECO_VALIDATION.py
#    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz cmsRun step2_DQM_RECO_VALIDATION.py
#    igprof-analyse -g -d -v -p -r MEM_LIVE -s step2_DQM_RECO_VALIDATION.gz | sqlite3 step2_DQM_RECO_VALIDATION_LIVE.sql3
    #igprof-analyse -g -d -v -p -r MEM_TOT -s step2_DQM_RECO_VALIDATION.gz | sqlite3 step2_DQM_RECO_VALIDATION_TOT.sql3
    #./py2html_new.py step2_DQM_RECO_VALIDATION.py >/dev/null
    ./py2html_new.py step2_DQM_RECO_VALIDATION.py step2_DQM_RECO_VALIDATION_LIVE.sql3
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valpreprod/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valpreprod/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VALPREPROD -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__valpreprod/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION PREPROD </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    cmsDriver.py step2_DQM -s RECO,VALIDATION:validation_prod -n 10 --eventcontent DQM --filein  file:/afs/cern.ch/cms/CAF/CMSCOMM/COMM_DQM/DQMTest/MinimumBias__RAW__v1__165633__1CC420EE-B686-E011-A788-0030487CD6E8.root --conditions auto:mc  --mc --no_exec --scenario ${SCENARIO}
    #python step2_DQM_RECO_VALIDATION.py
#    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz cmsRun step2_DQM_RECO_VALIDATION.py
#    igprof-analyse -g -d -v -p -r MEM_LIVE -s step2_DQM_RECO_VALIDATION.gz | sqlite3 step2_DQM_RECO_VALIDATION_LIVE.sql3
    #igprof-analyse -g -d -v -p -r MEM_TOT -s step2_DQM_RECO_VALIDATION.gz | sqlite3 step2_DQM_RECO_VALIDATION_TOT.sql3
    #./py2html_new.py step2_DQM_RECO_VALIDATION.py >/dev/null
    ./py2html_new.py step2_DQM_RECO_VALIDATION.py step2_DQM_RECO_VALIDATION_LIVE.sql3
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valprod/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valprod/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VALPROD -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__valprod/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION PROD </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    cmsDriver.py step3 -s HARVESTING:dqmHarvesting --conditions auto:com10 --filein  file:/afs/cern.ch/cms/CAF/CMSCOMM/COMM_DQM/DQMTest/MinimumBias__RAW__v1__165633__1CC420EE-B686-E011-A788-0030487CD6E8.root --data --no_exec --scenario ${SCENARIO}
    #python step3_HARVESTING.py
#    igprof -d -t cmsRun -mp -z -o step3_HARVESTING.gz cmsRun step3_HARVESTING.py
#    igprof-analyse -g -d -v -p -r MEM_LIVE -s step3_HARVESTING.gz | sqlite3 step3_HARVESTING_LIVE.sql3
    #igprof-analyse -g -d -v -p -r MEM_TOT -s step3_HARVESTING.gz | sqlite3 step3_HARVESTING_LIVE.sql3
    #./py2html_new.py step3_HARVESTING.py >/dev/null
    ./py2html_new.py step3_HARVESTING.py step3_HARVESTING_LIVE.sql3
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step3
    cp -pr html /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step3
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_HAR -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}/step3/html/index.html\" >${RELEASE} - Step3 - HARVESTING </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html
}

makeSequences()
{
  for SCENARIO in pp HeavyIons #cosmics
  do
    createSequences
  done
}

export PATH=$PATH:/afs/cern.ch/cms/common
export CVSROOT=:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
export CMS_PATH=/afs/cern.ch/cms

#export SCRAM_ARCH=slc5_amd64_gcc462
#RELEASE=CMSSW_5_2_X_`date +%Y-%m-%d-0200`
SER=6_2
#RELEASE=`curl -s -k https://cmstags.cern.ch/tc/py_getIBs\?filt\=${SER}\&limit\=5 | gawk --field-separator=']' '{print $4}' | gawk '{print $2}' | tr -d '[' | tr -d '"' | tr -d ','`
RELEASE=$1
echo "Using release ${RELEASE}"
#RELEASE=CMSSW_5_2_3_patch1
cd /home/DQMHisto

createRelease
if [ $? -eq 1 ]; then
  echo "makeSequences for $RELEASE"
  makeSequences
  #createHistogramOrigin
fi
removeRelease
