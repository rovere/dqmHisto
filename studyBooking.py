#!/usr/bin/env python

"""Parse a histogramBookingBT.log file, fill 2 dictionaries and write
them out in pickle format to speed-up load-time at the next
opening. The dictionaries are saved in two different pickle files, but
nothing prevents them to be saved in one unique file. The format of
histogramBookingBT.log is rather trivial, organized in logically
identical blocks and purely sequential in nature, w/o any
optimization. The first line contains the name of the histogram that
has been booked, a space, and the best candidate as the function
responsible for its booking. The heuristic on the real booking
function is done going up in the stack for a fixed amount of frames,
exactly the number of frames that are necessary to instrument the
intrusive monitoring of the booking policy. The following at most 10
lines represent the full stack trace of the calling process, up to 10
levels. These lines are preceeded by an order hint, of the type N/M to
tell at which level the corresponding call is in the overall
stack. This block is repeated as many times as many histograms are
booked by the monitored cmsRun process. The file is serially parsed
and the content of the file is transferred, in an optimized way, into
2 dictionaries, stack and call_stack. The stack dictionary uses the
md5.hexdigest hash of all the functions in all the printed stack as
the key, with the correspondin ASCCI version as a value. Duplicate
insertion/collisions are avoided checking the uniqueness of the key
before insertion into the dictionary. The call_stack dictionary uses
the ASCII histogram name as key, and an ordered array of md5.hexdigest
keys as values, each key corresponding to the proper function in the
stack trace of that particular histogram. The usage of dictionaries is
motivate by performance reasons: access by key is guaranteed to happen
in constant time. The dictionaries have been chosen as such to be able
to search using regexp on ASCII keys (histogram names, folder, and
subfolder at whatever level in the folder hierarchy!) in linear time
(bad...) and to rebuild the stack trace in constant time by direct
access by keys (matched histograms name and the hash keys in the
corresponding array).

The usage is rather trivial. The FIRST time this script is run the
user has to supply the histogramBookingBT.log file. The script will
then parse it, fill the dicitonary and write them out into to fixed
files: call_stack.pkl and stack.pkl, whose names are
self-explanatory. The script then enters and infinite loop waitiing
for an input search string from the console by the user. The input
MUST be a valid regexp string, or otherwise it will be ignored. The
results are precomputed and only the first match is served in an
aggregated way: the user is then asked to retrieve all other records,
one by one, or to quit and make another query. The SECOND time the
script is run, the user can directly supply the 2 pickled files
produced the first time the script has been run: in this case the load
time is < 1 sec. The resct of the logic is the same as the one already
described.

NOTE: no check, no options, no customizations have been added so far:
this was the result of a quick and dirty hack to have something to use
instead of grep via shell. The script can be, of course, greately
improved, but all the core functionalities are already there.

"""

#import sys
import re
import hashlib
import cPickle
import os
import sys

stack = {}
call_stack = {}
function_stack = {}
histo = re.compile('^"(.*)"')
call = re.compile("^\s+\d+/\d+\s+(.*)")
function_library = re.compile("([^/]*)\s+(.*)")

def hasher(value):
    """
    Helper function to return the md5.hexdigest() hash of any
    value
    """

    hasher = hashlib.md5()
    hasher.update(value)
    return hasher.hexdigest()

def fill_dictionaries(filename):
    """
    Helper function to fill the stack and call_stack dictionaries,
    fetching information out of the supplied filename
    """

    global stack
    global call_stack

    #before filling we want to clear existing entries in global dicts
    stack = {}
    call_stack = {}

    f = open(filename)
    histogram_name = None
    for f in f.readlines():
        m = re.match(histo, f.strip('\n'))
        if m:
            histogram_name = m.group(1)
            if histogram_name in call_stack:
                continue
            call_stack[histogram_name] = [] ## this will take only last entry of histogram in logs
            continue                        ## what to do with multiple entries? with harvesting step?
        m = re.match(call, f.strip('\n'))
        if m:
            key = hasher(m.group(1))
            if key not in stack.keys():
                stack[key] = m.group(1)
                if not m.group(1) in function_stack:
                    function_stack[m.group(1)] = []
            if len(call_stack[histogram_name]) >= 10: ## lame implementation for now
                continue                              ## we should check with histo booked only on Harvesting
            call_stack[histogram_name].append(key)
            function_stack[m.group(1)].append(histogram_name)
    print "Done importing information"

def readPickles(call_stack_file, stack_file, function_stack_file):
    """
    Helper function to read call_stack.pkl and stack.pkl files and
    fill in the corresponding dictionaries. The files to be read must
    be supplied by the user namely call_stack.pkl stack.pkl.
    NO CHECKS ARE PERFORMED TOVALIDATE THE CORRECTNESS OF THE ORDER.
    """

    global stack
    global call_stack
    global function_stack

    if call_stack_file != None and stack_file != None and function_stack_file != None:
        call_stack_w = open(call_stack_file, 'r')
        stack_w = open(stack_file, 'r')
        function_stack_w = open(function_stack_file, 'r')
        call_stack = cPickle.load(call_stack_w)
        stack = cPickle.load(stack_w)
        function_stack = cPickle.load(function_stack_w)
        return True
    return False

def writePickles(work_dir):
    """
    Helper function to write the content of call_stack and stack
    dictionaries into the corresponding pickled files. The output
    filenames are hard-coded in the code and cannot be customized via
    command line parameters.
    """

    global stack
    global call_stack
    global function_stack

    call_stack_w = open(os.path.join(work_dir,'call_stack.pkl'), 'w')
    stack_w = open(os.path.join(work_dir,'stack.pkl'), 'w')
    function_stack_w = open(os.path.join(work_dir,'function_stack.pkl'), 'w')
    cPickle.dump(call_stack, call_stack_w)
    cPickle.dump(stack, stack_w)
    cPickle.dump(function_stack, function_stack_w)

#if __name__ == '__main__':
def searchInfo(search_input, file_name=None,
        call_stack_file = None, stack_file = None, function_stack_file = None):

    """
    Main method for searching hashed pickle files.
    Input is histogram name to be converted to regexp and searched.
    """

    try:
        if not readPickles(call_stack_file, stack_file, function_stack_file):
            fill_dictionaries(file_name)
            work_dir = os.sep.join(file_name.split(os.sep)[:-1]) # get the base path to directory where histograms log exists
            writePickles(work_dir)
    except Exception as ex:
        print "ERROR while generating input files: %s" % (str(ex))
        return {"error": "Error: %s" % (str(ex))}

    search = None
    try:
        search = re.compile(search_input)
    except Exception:
        return {"error": "Error parsing regexp"}
    results = {}
    for histogram in call_stack.keys():
        if search and re.match(search, histogram):
            results[histogram] = []
            for calls in call_stack[histogram]:
                m = re.match(function_library, stack[calls])
                if m:
                    results[histogram].append("\t%s\n\t  %s" % (m.group(1), m.group(2)))

    print "Found %d results" % len(results.keys())
    return results

def searchFunctionStack(search_input, file_name=None,
        call_stack_file=None, stack_file=None, function_stack_file=None):

    try:
        if not readPickles(call_stack_file, stack_file, function_stack_file):
            fill_dictionaries(file_name)
            work_dir = os.sep.join(file_name.split(os.sep)[:-1]) # get the base path to directory where histograms log exists
            writePickles(work_dir)
    except Exception as ex:
        print "ERROR while generating input files: %s" % (str(ex))
        return {"error": "Error: %s" % (str(ex))}

    search = None
    try:
        search = re.compile(search_input)
    except Exception:
        return {"error": "Not a valid regexp"}
    results = {}
    for function in function_stack.keys():
        m = re.match(search,function)
        if m:
            #f = re.match(function_library,function)
            #if f:
            #    results[f.group(1)] = function_stack[function]
            for elem in function_stack[function]:
                results[elem] = [];
                for call in call_stack[elem]:
                    m = re.match(function_library, stack[call])
                    if m:
                        results[elem].append("\t%s\n\t  %s" % (m.group(1), m.group(2)))
                    #results[elem].append(stack[call])
    return results
