#!/bin/bash

#  Shell script to set CMSSW release, check-out DQM Tests.
#  Runs whiteRabbit's 3rd test with verbosity set to 5 to get histogram booking log file

export SCRAM_ARCH="slc6_amd64_gcc530"
#echo $SCRAM_ARCH
echo "working for $1"
export PATH=$PATH:/cvmfs/cms.cern.ch/common/
export CMS_PATH=/cvmfs/cms.cern.ch/

echo $PATH

ls -l /cvmfs/cms.cern.ch
scram p "$1"
cd "$1/src"
eval $(scram r -sh)
git cms-addpkg DQMServices/Components -q
echo "$LOCALRT"
scram b -j 2
#sed -i 's/process.DQMStore.verbose = cms.untracked.int32(2)/process.DQMStore.verbose = cms.untracked.int32(5)/g' "$LOCALRT/src/DQMServices/Components/python/test/customDQM.py"
sed -i 's/process.load("DQMServices.Components.DQMStoreStats_cfi")/process.load("DQMServices.Components.DQMStoreStats_cfi")\n    process.DQMStore.verbose = cms.untracked.int32(5)/g' "$LOCALRT/src/DQMServices/Components/python/test/customRecoSim.py"
sed -i 's/process.load("DQMServices.Components.DQMStoreStats_cfi")/process.load("DQMServices.Components.DQMStoreStats_cfi")\n    process.DQMStore.verbose = cms.untracked.int32(5)/g' "$LOCALRT/src/DQMServices/Components/python/test/customHarvesting.py"
echo "mv histogramBookingBT.log histogramBookingBT.log1" >> $LOCALRT/src/DQMServices/Components/test/driver3a.sh
echo "mv histogramBookingBT.log histogramBookingBT.log2" >> $LOCALRT/src/DQMServices/Components/test/driver3b.sh
#cat $LOCALRT/src/DQMServices/Components/python/test/customRecoSim.py
#scram b -j 2
echo "  --^.^-- Lets run WhiteRabbit! --^.^--"
cd "$LOCALRT/src/DQMServices/Components/test"
python whiteRabbit.py -n3 -q1
echo "  ## whiteRabbit finished. Lets move report ##"
OUT_DIR=`ls -l $LOCALRT/src/DQMServices/Components/test| egrep '^d' | grep -v 'CVS' | awk '{print $9}'`
echo $OUT_DIR
cat $LOCALRT/src/DQMServices/Components/test/$OUT_DIR/3/histogramBookingBT.log* >> $LOCALRT/src/DQMServices/Components/test/$OUT_DIR/3/histogramBookingBT.log
mkdir -p "/home/DQMHisto/report/$1"
cp "$LOCALRT/src/DQMServices/Components/test/$OUT_DIR/3/histogramBookingBT.log" "/home/DQMHisto/report/$1/histogramBookingBT.log"
rm -rf $LOCALRT #remove CMSSW directory that we worked on - save disk space
