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
      cp /home/DQMHisto/dqmHisto/py2html_new.py  .
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

createPhaseIISequence()
{
# Taken from wfl 24034 of runTheMatrix
  echo "working directory: $PWD and files"
# GEN-SIM
  cmsDriver.py TTbar_14TeV_TuneCUETP8M1_cfi --conditions auto:phase2_realistic \
    -n 2 --era Phase2C2 --eventcontent FEVTDEBUG --relval 9000,50 -s GEN,SIM \
    --datatier GEN-SIM --beamspot HLLHC14TeV --geometry Extended2023D11 \
    --fileout file:step1.root
  if [ $? -ne 0 ]; then
    return 1
  fi

#DIGI
  cmsDriver.py step2  --conditions auto:phase2_realistic \
    -s DIGI:pdigi_valid,L1,L1TrackTrigger,DIGI2RAW,HLT:@fake2 --datatier GEN-SIM-DIGI-RAW -n -1 \
    --geometry Extended2023D11 --era Phase2C2 --eventcontent FEVTDEBUGHLT \
    --filein file:step1.root  --fileout file:step2.root
  if [ $? -ne 0 ]; then
    return 1
  fi

# RECO-DQM-VALIDATION
  cmsDriver.py step3  --conditions auto:phase2_realistic -n -1 \
    --era Phase2C2 --eventcontent RECOSIM,MINIAODSIM,DQM --runUnscheduled  \
    -s RAW2DIGI,L1Reco,RECO,PAT,VALIDATION:@iphase2Validation+@miniAODValidation,DQM:@phase2+@miniAODDQM \
    --datatier GEN-SIM-RECO,MINIAODSIM,DQMIO --geometry Extended2023D11 \
    --filein file:step2.root  --fileout file:step3.root
  if [ $? -ne 0 ]; then
    return 1
  fi
# Get rid of unscheduled execution to have a meaningful dump
  sed -i -e 's/\(.*convertToUnscheduled(.*\)/#\1/' step3_RAW2DIGI_L1Reco_RECO_PAT_VALIDATION_DQM.py
  ./py2html_new.py  -i step3_RAW2DIGI_L1Reco_RECO_PAT_VALIDATION_DQM.py -o .

  mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseII/step2
  mv html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseII/step2
  sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_DQM -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__PhaseII/step2/html/index.html\" >${RELEASE} - Step2 - PhaseII DQM+VALIDATION </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

# HARVESTING
  cmsDriver.py step5  --conditions auto:phase2_realistic \
    -s HARVESTING:@phase2Validation+@phase2++@miniAODValidation+@miniAODDQM --era Phase2C2 \
    --filein file:step3_inDQM.root --scenario pp --filetype DQM \
    --geometry Extended2023D11 --mc -n 1  --fileout file:step5.root

  if [ $? -ne 0 ]; then
    return 1
  fi
  ./py2html_new.py  -i step5_HARVESTING.py -o .

  mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseII/step3
  mv html /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseII/step3
  sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_HAR -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__PhaseII/step3/html/index.html\" >${RELEASE} - Step3 - PhaseII HARVESTING </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html
}

createPhaseISequence()
{
  echo "working directory: $PWD and files"
# GEN-SIM
  cmsDriver.py TTbar_13TeV_TuneCUETP8M1_cfi  --conditions auto:phase1_2017_realistic \
    -n 2 --era Run2_2017 --eventcontent FEVTDEBUG --relval 9000,50 -s GEN,SIM \
    --datatier GEN-SIM --beamspot Realistic50ns13TeVCollision --geometry DB:Extended \
    --fileout file:step1.root
  if [ $? -ne 0 ]; then
    return 1
  fi

#DIGI
  cmsDriver.py step2  --conditions auto:phase1_2017_realistic \
    -s DIGI:pdigi_valid,L1,DIGI2RAW,HLT:@relval2017 --datatier GEN-SIM-DIGI-RAW -n -1 \
    --geometry DB:Extended --era Run2_2017 --eventcontent FEVTDEBUGHLT \
    --filein file:step1.root  --fileout file:step2.root
  if [ $? -ne 0 ]; then
    return 1
  fi

# RECO-DQM-VALIDATION
  cmsDriver.py step3  --conditions auto:phase1_2017_realistic -n -1 \
    --era Run2_2017 --eventcontent RECOSIM,MINIAODSIM,DQM --runUnscheduled  \
    -s RAW2DIGI,L1Reco,RECO,EI,PAT,VALIDATION:@standardValidation+@miniAODValidation,DQM:@standardDQM+@miniAODDQM \
    --datatier GEN-SIM-RECO,MINIAODSIM,DQMIO --geometry DB:Extended \
    --filein file:step2.root  --fileout file:step3.root
  if [ $? -ne 0 ]; then
    return 1
  fi
# Get rid of unscheduled execution to have a meaningful dump
  sed -i -e 's/\(.*convertToUnscheduled(.*\)/#\1/' step3_RAW2DIGI_L1Reco_RECO_EI_PAT_VALIDATION_DQM.py
  ./py2html_new.py  -i step3_RAW2DIGI_L1Reco_RECO_EI_PAT_VALIDATION_DQM.py -o .

  mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseI/step2
  mv html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseI/step2
  sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_DQM -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__PhaseI/step2/html/index.html\" >${RELEASE} - Step2 - PhaseI DQM+VALIDATION </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

# HARVESTING
  cmsDriver.py step5  --conditions auto:phase1_2017_realistic \
    -s HARVESTING:@standardValidation+@standardDQM --era Run2_2017 \
    --filein file:step3_inDQM.root --scenario pp --filetype DQM \
    --geometry DB:Extended --mc -n 1  --fileout file:step5.root

  if [ $? -ne 0 ]; then
    return 1
  fi
  ./py2html_new.py  -i step5_HARVESTING.py -o .

  mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseI/step3
  mv html /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__PhaseI/step3
  sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_HAR -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__PhaseI/step3/html/index.html\" >${RELEASE} - Step3 - PhaseI HARVESTING </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html
}

createSequences()
{
    echo "working directory: $PWD and files"
    pwd & ls
    ##GEN-SIM step
    if [ "$CONDS" = "auto:mc" ];then
    cmsDriver.py SingleMuPt10_pythia8.cfi -s GEN,SIM,DIGI:pdigi_valid,L1,DIGI2RAW \
      -n 2 --eventcontent FEVTDEBUG --datatier FEVTDEBUG \
      --conditions ${CONDS} --mc --no_exec
    else
      cmsDriver.py SingleMuPt10_pythia8.cfi -s GEN,SIM,DIGI:pdigi_valid,L1,DIGI2RAW \
        -n 2 --eventcontent FEVTDEBUG --datatier FEVTDEBUG \
        --conditions auto:upgradePLS3 --mc --no_exec  \
        --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,\
        SLHCUpgradeSimulations/Configuration/phase1TkCustoms.customise --geometry Extended2017
    fi
    cmsRun SingleMuPt10_pythia8_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.py

    ##DQM step
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,DQM -n 2 \
      --filein file:SingleMuPt10_pythia8_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions ${CONDS} \
      --mc --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_DQM.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_DQM.py &> /dev/null

    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_DQM.gz | sqlite3 \
      step2_DQM_RECO_DQM_TOT.sql3
    ./py2html_new.py  -i step2_MC1_4_RAW2DIGI_RECO_DQM.py -p step2_DQM_RECO_DQM_TOT.sql3 -o .
    echo "dqm return code: $?"
    if [ $? -ne 0 ]; then
      return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step2
    mv html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_DQM -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}/step2/html/index.html\" >${RELEASE} - Step2 - DQM </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    ##Validation step
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,VALIDATION -n 2 \
      --filein file:SingleMuPt10_pythia8_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions ${CONDS} --mc \
      --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py &> /dev/null
    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_VALIDATION.gz | sqlite3 \
      step2_DQM_RECO_VALIDATION_TOT.sql3
    ./py2html_new.py  -i step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py -p step2_DQM_RECO_VALIDATION_TOT.sql3 -o .
    echo "val return code: $?"
    if [ $? -ne 0 ]; then
      return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__val/step2
    mv html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__val/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VAL -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__val/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    #Validation:preprod
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,VALIDATION:validation_preprod -n 2 \
      --filein file:SingleMuPt10_pythia8_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions $CONDS --mc \
      --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py &> /dev/null
    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_VALIDATION.gz | sqlite3 \
      step2_DQM_RECO_VALIDATION_TOT.sql3
    ./py2html_new.py  -i step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py -p step2_DQM_RECO_VALIDATION_TOT.sql3 -o .
    echo "val:preprod return code: $?"
    if [ $? -ne 0 ]; then
      return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valpreprod/step2
    mv html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valpreprod/step2
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_VALPREPROD -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}__valpreprod/step2/html/index.html\" >${RELEASE} - Step2 - VALIDATION PREPROD </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html

    #Validation:prod
    cmsDriver.py step2_MC1_4 -s RAW2DIGI,RECO,VALIDATION:validation_prod -n 2 \
      --filein file:SingleMuPt10_pythia8_cfi_GEN_SIM_DIGI_L1_DIGI2RAW.root \
      --eventcontent RECOSIM,DQM --datatier RECOSIM,DQMROOT --conditions ${CONDS} --mc \
      --no_exec --scenario ${SCENARIO}
    igprof -d -t cmsRun -mp -z -o step2_DQM_RECO_VALIDATION.gz \
      cmsRun step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py &> /dev/null
    igprof-analyse -g -d -v -r MEM_TOTAL -s step2_DQM_RECO_VALIDATION.gz | sqlite3 \
      step2_DQM_RECO_VALIDATION_TOT.sql3
    ./py2html_new.py  -i step2_MC1_4_RAW2DIGI_RECO_VALIDATION.py -p step2_DQM_RECO_VALIDATION_TOT.sql3 -o .
    echo "val:prod return code: $?"
    if [ $? -ne 0 ]; then
      return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valprod/step2
    mv html  /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}__valprod/step2
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
    ./py2html_new.py  -i step3_MC1_4_HARVESTING.py -p step3_HARVESTING_TOT.sql3 -o .
    echo "harvesting return code: $?"
    if [ $? -ne 0 ]; then
      return 1
    fi
    mkdir -p /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step3
    mv html /home/DQMHisto/DQMSequences/${SCENARIO}__${RELEASE}/step3
    sed -i -e "s#\(.*<!-- PLACEHOLDER_${SCENARIO}_HAR -->\)#  <li> <a href=\"sequences/${SCENARIO}__${RELEASE}/step3/html/index.html\" >${RELEASE} - Step3 - HARVESTING </a> </li> \n\1#" /home/DQMHisto/dqmHisto/static/config_browser.html
}

makeSequences()
{
  for SCENARIO in cosmics HeavyIons pp
  do
    createSequences
  done
  createPhaseISequence
  createPhaseIISequence
}

export PATH=$PATH:/cvmfs/cms.cern.ch/common/
export CMS_PATH=/cvmfs/cms.cern.ch/

##ls cvmfs in case its not mounted, to make autofs to mount it
ls -l /cvmfs/cms.cern.ch
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
