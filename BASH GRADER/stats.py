import numpy as np
import matplotlib.pyplot as plt
import csv
import sys

### These are all the statistics function  that generates the stats using numpy ###
def mean(marks) :
    return np.round(np.mean(marks,axis= 0),decimals=2)

def stdDev(marks) :
    return np.round(np.std(marks,axis=0),decimals=2)

def median(marks) :
    return np.round(np.median(marks,axis=0),decimals=2)

def highestMarks(marks):
    return np.max(marks, axis=0)

def lowestMarks(marks):
    return np.min(marks, axis=0)

def thirdQuartile(marks) :
    return np.round(np.percentile(marks, 75 , axis= 0),decimals=2)


### This function creates a csv file named stats.csv which has mean , meadian , std devatiation , third quartile ###
def stats_student(examName,marks) :
    with open("stats.csv",'w',newline='') as csvfile :
        myfile = csv.writer(csvfile)
        myfile.writerow(["","Mean","Median","Standard Deviation","Third Quartile"])
        meanMarks = mean(marks)
        medianMarks = median(marks)
        standardDeviation = stdDev(marks)
        third = thirdQuartile(marks)
        for i in range(len(examName)) :
            myfile.writerow([examName[i],meanMarks[i],medianMarks[i],standardDeviation[i],third[i]])


### This function creates a csv file named stats.csv which has mean , meadian , std devatiation , third quartile , max and min marks ###
def stats(examName,marks) :
    with open("stats.csv",'w',newline='') as csvfile :
        myfile = csv.writer(csvfile)
        myfile.writerow(["ExamName","Mean","Median","Standard Deviation","Third Quartile","Maximum Marks","Minimum Marks"])
        meanMarks = mean(marks)
        medianMarks = median(marks)
        standardDeviation = stdDev(marks)
        third = thirdQuartile(marks)
        maxMarks = highestMarks(marks)
        minMarks = lowestMarks(marks)
        for i in range(len(examName)) :
            myfile.writerow([examName[i],meanMarks[i],medianMarks[i],standardDeviation[i],third[i],maxMarks[i],minMarks[i]])


### The below uses numpy function loadtext and then generates a numpy array 
rollNumber = np.char.lower(np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,0])
name = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,1]
examName = np.loadtxt("main.csv",delimiter="," ,dtype=str)[0,2:]
marks = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,2:]
marks_upd = np.where(marks == "a", "0" , marks)
studentMarks = marks_upd.astype(float)


### this is used when the submission.sh call the bash function ###
if sys.argv[1] == "reportCard" :
    stats_student(examName,studentMarks)

if sys.argv[1] == "statistics" :
    stats(examName,studentMarks)

