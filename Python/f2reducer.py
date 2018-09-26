#!/usr/bin/env python3
#Be sure the indentation is correct and also be sure the line above this is on the first line
 
import sys


if __name__ == '__main__':
    lines = sys.stdin.readlines()

    my_data = {}

    for line in lines:	
        cleanline = line.strip()


        mykey = cleanline.split("\t",1)[0]
        myval = cleanline.split("\t",1)[1]
        myval_int = int(myval)

        if mykey in my_data:
            my_data[mykey] += myval_int

        else:
            my_data[mykey] = myval_int

    quickesttime = min(my_data.values())
    keys = [ k for k in my_data if my_data[k] == quickesttime]
    for onekey in keys:
        buildingnolist = onekey.split(" ")
        outputstr = []
        for buildingno in buildingnolist:

           buildingname = 'Building' + str(int(buildingno) + 1)
           outputstr.append(buildingname)
        print(" ".join(str(myblah) for myblah in outputstr), "\t", quickesttime)
