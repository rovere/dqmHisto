import os
import subprocess

__report_dir = os.path.join("..","report")

existing_reports = os.listdir(__report_dir)

for report in existing_reports:
    available_files = os.listdir(os.path.join(__report_dir, report))
    if "histogramBookingBT.log" in available_files:
        print report, " histogramBookingBT exists. curl url and remove the file"
        if "call_stack.pkl" in available_files and "stack.pkl" in available_files and \
        "function_stack.pkl" in available_files:
            print "We are safe to remove histogramBookingBT from release: ", report
            os.remove(os.path.join(__report_dir, report, "histogramBookingBT.log"))
        else:
            #we curl here
            url = "http://cms-dqm-histo.cern.ch/report/%s/.*L1T.*/true" % (report)
            args = ["curl", url]
            p = subprocess.Popen(args)
            p.communicate()[0]
            currently_available_files = os.listdir(os.path.join(__report_dir, report))
            if "call_stack.pkl" in currently_available_files and "stack.pkl" in \
            currently_available_files and "function_stack.pkl" in currently_available_files:
                print "Removing histogram log..."
                os.remove(os.path.join(__report_dir, report, "histogramBookingBT.log"))
            else:
                print "wrong number of files: ", report