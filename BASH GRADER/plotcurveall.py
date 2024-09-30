import numpy as np
import matplotlib.pyplot as plt
import grades
import sys

### This grading_curve plot a histogram of freqency of grades ###
def grading_curve(studentGrades):
    ### assining values to grades so that they can be plotted and at end the values are 
    #replaced by grade names using xticks function
    grade_values = {'FF':1,'DD':2,'CD':3,'CC' : 4,'BC' : 5,'BB' : 6,'AB' : 7,'AA' : 8,'AP' : 9}
    numerical_grades = [grade_values[grade] for grade in studentGrades.values()]
    numerical_grades_np = np.array(numerical_grades)

    ### Counting max num of grades to set limit of y ticks ###
    maxNumGrades = np.count_nonzero(numerical_grades_np == np.argmax(numerical_grades_np))

    plt.hist(numerical_grades, bins=range(1, 11), color='skyblue', edgecolor='black', alpha=0.7)

    plt.xlabel('Grade')
    plt.ylabel('Frequency')
    plt.title('Histogram of Grades')
    
    plt.yticks(np.arange(0,maxNumGrades+2,1))
    plt.xticks(np.arange(1.5,10.5,1), list(grade_values.keys()))

    plt.savefig("Histrogram Of Grades")

### this to used to sort the grades based on the order given below ###
desired_order = ['FF','DD','CD', 'CC', 'BC', 'BB', 'AB', 'AA', 'AP']

def custom_sort_key(item):
    return desired_order.index(item)

### this makes a piechart for the studentGrades
def grading_piechart(studentGrades) :
    gradesCounts = {}
    for element in studentGrades.values():
        if element in gradesCounts:
            gradesCounts[element] += 1
        else:
            gradesCounts[element] = 1

    grades_ocuurence=np.array((list(gradesCounts.values())))
    labels = gradesCounts.keys()

    plt.pie(grades_ocuurence,labels=labels,autopct='%1.1f%%')
    plt.title("Pie chart of Grades")
    plt.savefig("Pie Chart of Grades")


rollNumber = np.char.lower(np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,0])
name = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,1]
examName = np.loadtxt("main.csv",delimiter="," ,dtype=str)[0,2:]
marks = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,2:]
marks_upd = np.where(marks == "a", "0" , marks)
studentMarks = marks_upd.astype(float)

if sys.argv[1] == "studentGrades" :
    GRADES = list(grades.grades(studentMarks,rollNumber).items())
    SortedDict = dict(sorted(GRADES,key= lambda x : custom_sort_key(x[1])))
    grading_curve(SortedDict)
    grading_piechart(SortedDict)
