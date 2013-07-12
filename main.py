"""
 Wheres my histogram server code!
"""

import os
import json
import re
from flask import Flask, url_for, redirect
from werkzeug.contrib.cache import SimpleCache

from studyBooking import *
app = Flask(__name__)

__cache = SimpleCache()


class MainInfo():
    """
    Main class for storing possible reports and methods to get information
    """
    def __init__(self):
        self.report_dir = os.path.join(os.getcwd(),"../report")
        if not os.path.exists(self.report_dir):
            os.makedirs(self.report_dir)
        self.available_reports = os.listdir(self.report_dir) 

@app.route('/')
def hello_world():
    info = MainInfo()
    return redirect(url_for('static', filename='index.html'))

@app.route('/list_reports')
def list_reports():
    info = MainInfo()
    return json.dumps({"results": info.available_reports})

#@app.route('/test/<release>/<path:search_input>')
#def get_data_for_booking(release, search_input):
#    #results = searchLogs(release, search_input,False)
#    return {"results": "rest function"}

@app.route('/report/<release>/<path:search_input>/<searchByHistogram>')
def get_data(release,search_input,searchByHistogram):
    if searchByHistogram == 'true':
        results = searchLogs(release, search_input)
    else:
        results = searchLogs(release, search_input,False)
    return results

def searchLogs(release, searchable, search_by_histogram=True):
    info = MainInfo()
    data = {}
    if release not in info.available_reports:
        return json.dumps({"results": "release not in available list"})
    path = os.path.join(os.getcwd(),"..","report",release)
    if os.path.exists(os.path.join(path,"call_stack.pkl")) and os.path.exists(os.path.join(path,"stack.pkl")):
        cache_name = release+"-"+searchable
        data = __cache.get(cache_name)
        if data is None:
            call_stack_file = os.path.join(path,"call_stack.pkl")
            stack_file = os.path.join(path,"stack.pkl")
            if search_by_histogram:
                data = searchInfo(searchable, call_stack_file = call_stack_file, stack_file = stack_file)
            else:
                data = searchInfoBooking(searchable, call_stack_file = call_stack_file, stack_file = stack_file)
            print len(data.keys())
            __cache.set(cache_name, data,timeout=3000)
        return json.dumps({"results": "pkls exists", "data":data})
    else:
        cache_name = release+"-"+searchable
        data = __cache.get(cache_name)
        if data is None:
            if search_by_histogram:
                data = searchInfo(searchable, file_name=os.path.join(path,"histogramBookingBT.log"))
            else:
                data = searchInfoBooking(searchable, file_name=os.path.join(path,"histogramBookingBT.log"))
            __cache.set(cache_name, data,timeout=3000)
        return json.dumps({"results for histogramBooking.log": os.path.exists(os.path.join(path,"histogramBookingBT.log")), "data": data})

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=80)