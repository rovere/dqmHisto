"""
 Wheres my histogram server code!
"""

import os
import json
import re
from flask import Flask, url_for, redirect
from studyBooking import *
app = Flask(__name__)

#stack = {}
#call_stack = {}
#histo = re.compile('^"(.*)"')
#call = re.compile("^\s+\d+/\d+\s+(.*)")
#function_library = re.compile("([^/]*)\s+(.*)")


class MainInfo():
    """
    Main class for storing possible reports and methods to get information
    """
    def __init__(self):
        self.report_dir = "report"
        self.available_reports = os.listdir(os.path.join(os.getcwd(),self.report_dir))
  

@app.route('/')
def hello_world():
    info = MainInfo()
    return redirect(url_for('static', filename='index.html'))
    #return json.dumps({"results": info.available_reports})

@app.route('/list_reports')
def list_reports():
    info = MainInfo()
    return json.dumps({"results": info.available_reports})

#@app.route('/test')
#def test():
#    #info = MainInfo()
#    return redirect(url_for('static', filename='index.html'))


@app.route('/report/<release>/<path:histogram>')
def get_data(release,histogram):
    info = MainInfo()
    data = {}
    if release not in info.available_reports:
        return json.dumps({"results": "release not in available list"})
    path = os.path.join(os.getcwd(),"report",release)
    if os.path.exists(os.path.join(path,"call_stack.pkl")) and os.path.exists(os.path.join(path,"stack.pkl")):
        call_stack_file = os.path.join(path,"call_stack.pkl")
	stack_file = os.path.join(path,"stack.pkl")

        data = searchInfo(histogram, call_stack_file = call_stack_file, stack_file = stack_file)
        print len(data.keys())
        return json.dumps({"results": "pkls exists", "data":data})
    else:
        data = searchInfo(histogram, file_name=os.path.join(path,"histogramBookingBT.log"))
        return json.dumps({"results for histogramBooking.log": os.path.exists(os.path.join(path,"histogramBookingBT.log")), "data": data})

    


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=80)
