#!/bin/bash

#  Shell script to set CMSSW release, check-out DQM Tests.
#  Runs whiteRabbit's 11th test with verbosity set to 5 to get histogram booking log file

export SCRAM_ARCH="slc5_amd64_gcc472"
echo $SCRAM_ARCH
echo "working for $1"
source /afs/cern.ch/cms/LCG/LCG-2/UI/cms_ui_env.sh
export PATH=$PATH:/afs/cern.ch/cms/common
export CVSROOT=:gserver:cmssw.cvs.cern.ch:/local/reps/CMSSW
export CMS_PATH=/afs/cern.ch/cms
echo $PATH
scram p "$1"
cd "$1/src"
eval $(scram r -sh)
addpkg DQMServices/Components
echo "$LOCALRT"
scram b -j 2
sed -i 's/process.DQMStore.verbose = cms.untracked.int32(2)/process.DQMStore.verbose = cms.untracked.int32(5)/g' "$LOCALRT/src/DQMServices/Components/python/test/customDQM.py"
#scram b -j 2
echo "  --^.^-- Lets run WhiteRabbit! --^.^--"
cd "$LOCALRT/src/DQMServices/Components/test"
python whiteRabbit.py -n11 -q1
echo "  ## whiteRabbit finished. Lets move report ##"
OUT_DIR=`ls -l $LOCALRT/src/DQMServices/Components/test| egrep '^d' | grep -v 'CVS' | awk '{print $9}'`
echo $OUT_DIR
mkdir -p "/home/DQMHisto/report/$1"
cp "$LOCALRT/src/DQMServices/Components/test/$OUT_DIR/11/histogramBookingBT.log" "/home/DQMHisto/report/$1/histogramBookingBT.log"
rm -rf $LOCALRT #remove CMSSW directory that we worked on - save disk space
