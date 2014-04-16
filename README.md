dqmHisto
========

'where's that histogram located' service 

DQM service to display histogram booking logs for users.
uses Flask python web server

main.py - main server with methods to serve static HTML and information abou histogram booking;
checkNewCMSSW.py - python script thats being run by acrontab everyday to check for new CMSSW versions in AFS
studyBooking.py - module to search for information about histogram from histogrambooking.log or from pkls 
files
test.sh - shell script to set-up CMSSW environment, prepare DQMService package, do whiterabbit 3rd test, and 
move report to 'reports' directory for serving by main.py
