#!/usr/bin/env python3
#Be sure the indentation is correct and also be sure the line above this is on the first line
 
import sys
import itertools
def main(argv):
    lines = sys.stdin.readlines()

    for line in lines:	
        cleanline = line.strip()
        
        before_colon = cleanline.split(":",1)[0]
        after_colon = cleanline.split(":",1)[1]

       


       
        time_to_travel = [int(x) for x in after_colon.split()]
        buildingname = before_colon.strip()

        this_building = str(time_to_travel.index(0))
        i = len(time_to_travel) - 1
        for pathlist in itertools.permutations(list(range(1,i+1)),i):

            path = " ".join(str(myblah) for myblah in pathlist)
            journey = '0 ' + path + ' 0'
            destinationbuilding = 0;
            for this_time in time_to_travel:
                lineid = this_building + ' '+ str(destinationbuilding)
                if(lineid in journey):
                    print(journey, this_time, sep = "\t")
                destinationbuilding = destinationbuilding + 1


#Note there are two underscores around name and main
if __name__ == "__main__":
    main(sys.argv)



