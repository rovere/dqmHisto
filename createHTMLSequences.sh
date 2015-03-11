#!/bin/bash

createRelease()
{
    #cd /build/rovere/dqmOfflineSequences
    cd dqmOfflineSequences
    export SCRAM_ARCH=$ARCH
    echo $SCRAM_ARCH
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
    echo "working directory: $PWD and files"
    pwd & ls
    ##GEN-SIM step
    if [ "$CONDS" = "auto:mc" ];then
    cmsDriver.py SingleMuPt10.cfi -s GEN,SIM,DIGI:pdigi_valid,L1,DIGI2RAW \
      -n 2 --eventcontent FEVTDEBUG --datatier FEVTDEBUG \
      --conditions ${CONDS} --mc --no_exec
    else
      cmsDriver.py SingleMuPt10.cfi -s GEN,SIM,DIGI:pdigi_valid,L1,DIGI2RAW \
        -n 2 --eventcontent FEVTDEBUG --datatier FEVTDEBUG \
        --conditions auto:upgradePLS3 --mc --no_exec  \
        --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,\
        SLHCUpgradeSimulations/Configuration/phase1TkCustoms.customise --geometry Extended2017
    fi
    cmsRun SingleMuPt10_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.py

    ##DQM step
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,DQM -n 2 \
      --filein file:SingleMuPt10_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions ${CONDS} \
      --mc --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_DQM.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_DQM.py &> /dev/null

    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_DQM.gz | sqlite3 \
      step2_DQM_RECO_DQM_TOT.sql3
    ./py2html_new.py step2_MC1_4_RAW2DIGI_RECO_DQM.py step2_DQM_RECO_DQM_TOT.sql3
    echo "dqm return code: $?"
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_DQM -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}/step2/html/index.html\" >${RELEASE} - Step2 - DQM </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    ##Validation step
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,VALIDATION -n 2 \
      --filein file:SingleMuPt10_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions ${CONDS} --mc \
      --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py &> /dev/null
    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_VALIDATION.gz | sqlite3 \
      step2_DQM_RECO_VALIDATION_TOT.sql3
    ./py2html_new.py step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py step2_DQM_RECO_VALIDATION_TOT.sql3
    echo "val return code: $?"
    if [ $? -ne 0 ]; then
        return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__val/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__val/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VAL -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__val/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    #Validation:preprod
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,VALIDATION:validation_preprod -n 2 \
      --filein file:SingleMuPt10_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions $CONDS --mc \
      --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py &> /dev/null
    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_VALIDATION.gz | sqlite3 \
      step2_DQM_RECO_VALIDATION_TOT.sql3
    ./py2html_new.py step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py step2_DQM_RECO_VALIDATION_TOT.sql3
    echo "val:preprod return code: $?"
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valpreprod/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valpreprod/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VALPREPROD -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__valpreprod/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION PREPROD </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    #Validation:prod
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,VALIDATION:validation_prod -n 2 \
      --filein file:SingleMuPt10_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions ${CONDS} --mc \
      --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py &> /dev/null
    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_VALIDATION.gz | sqlite3 \
      step2_DQM_RECO_VALIDATION_TOT.sql3
    ./py2html_new.py step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py step2_DQM_RECO_VALIDATION_TOT.sql3
    echo "val:prod return code: $?"
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valprod/step2
    cp -pr html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valprod/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VALPROD -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__valprod/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION PROD </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    #Harvesting step
    cmsDriver.py step3_MC1_4 -s HARVESTING:dqmHarvesting --harvesting AtRunEnd \
      --conditions ${CONDS} --filetype DQM \
      --filein file:step2_MC1_4_RAW2DIGI_RECO_DQM_inDQM.root --mc --no_exec \
      --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step3_HARVESTING.gz \
      cmsRun step3_MC1_4_HARVESTING.py &> /dev/null
    igprof-analyse -g -d -v -r MEM_TOTAL -s step3_HARVESTING.gz | sqlite3 \
      step3_HARVESTING_TOT.sql3
    ./py2html_new.py step3_MC1_4_HARVESTING.py step3_HARVESTING_TOT.sql3
    echo "harvesting return code: $?"
    if [ $? -ne 0 ]; then
	return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step3
    cp -pr html /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step3
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_HAR -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}/step3/html/index.html\" >${RELEASE} - Step3 - HARVESTING </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html
}

makeSequences()
{
  for SCENARIO in cosmics pp HeavyIons
  do
    createSequences
  done
}

export PATH=$PATH:/afs/cern.ch/cms/common
export CVSROOT=:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
export CMS_PATH=/afs/cern.ch/cms

SER=6_2
RELEASE=$1
ARCH=$2
CONDS=$3
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
