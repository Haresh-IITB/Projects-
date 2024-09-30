import numpy as np
import matplotlib.pyplot as plt
import sys

### grading_curve takes studentGrades and gives back a dictionary of rollNumber and grades ###
def grades(studentMarks,rollNumber) :
    
    # Assign grades to each student
    student_grades = [assign_grade(mark,studentMarks[...,-1]) for mark in studentMarks[... , -1]]

    student_dict={}
    i=0
    for students in rollNumber :
        student_dict.update({students : student_grades[i]})
        i=i+1
    grades = list(student_dict.items())
    # SortedDict = sorted(grades,key= lambda x : custom_sort_key(x[1]))
    return dict(grades)


def assign_grade(mark,studentMarks):
    ### assigning grades based on the percentiles given in hte array ###

    grade_cutoffs = [np.percentile(studentMarks, i) for i in [98,90,75,50,30,20,10,5]]

    if mark >= grade_cutoffs[0]:
        return 'AP'
    elif mark >= grade_cutoffs[1]:
        return 'AA'
    elif mark >= grade_cutoffs[2]:
        return 'AB'
    elif mark >= grade_cutoffs[3]:
        return 'BB'
    elif mark >= grade_cutoffs[4]:
        return 'BC'
    elif mark >= grade_cutoffs[5]:
        return 'CC'
    elif mark >= grade_cutoffs[6]:
        return "CD"
    elif mark >= grade_cutoffs[7]:
        return 'DD'
    else :
        return 'FF'
### using the where function of numpy the grade of the student with a given rollNumber is founded out ###  
def gradeParticularStudent(grades,rollNumber,rollNumberStudent) :
    return str(np.array(list(grades.values()))[np.where(rollNumber ==  rollNumberStudent)][0])
### remarks based on the grade scored remark are given , these remarks are for overall performance ###
def remarks(grade):
    if grade == "AP":
        return "Outstanding performance! Your overall grade reflects exceptional understanding and mastery of the subject. Congratulations on your achievement."
    elif grade == "AA":
        return "Excellent work! Your overall grade indicates top-tier performance and strong grasp of the material. Keep up the great work."
    elif grade == "AB":
        return "Very good job! Your overall grade demonstrates above-average performance and solid comprehension of the subject matter."
    elif grade == "BB":
        return "Good effort! Your overall grade reflects satisfactory performance and understanding of the material. Keep striving for improvement."
    elif grade == "BC":
        return "Fair performance. Your overall grade indicates basic understanding, but there's room for improvement in certain areas. Keep working hard."
    elif grade == "CC":
        return "Below-average performance. Your overall grade suggests some difficulties grasping the material. Focus on areas that need improvement and seek help if needed."
    elif grade == "CD":
        return "Needs improvement. Your overall grade indicates significant challenges in understanding the material. Extra effort and attention are necessary to improve."
    elif grade == "DD":
        return "Poor performance. Your overall grade reflects serious deficiencies in understanding and application of the material. Immediate action is needed to address these issues."
    else :
        return "Fail. Your overall grade falls below the minimum standard required for passing. Remedial action and additional support are essential to improve your understanding and performance."


rollNumber = np.char.lower(np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,0])
name = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,1]
examName = np.loadtxt("main.csv",delimiter="," ,dtype=str)[0,2:]
marks = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,2:]
marks_upd = np.where(marks == "a", "0" , marks)
studentMarks = marks_upd.astype(float)

### making a txt file which have the grade of the particular student for which report is being made ### 
if sys.argv[1] == "reportCard" :
   
    f = open("gradeStudent.txt","w",newline="") 
    f.write(gradeParticularStudent(grades(studentMarks,rollNumber),rollNumber,sys.argv[2].lower()))
    f.close() 

    f = open("Overall.txt","w")
    f.write(remarks((gradeParticularStudent(grades(studentMarks,rollNumber),rollNumber,sys.argv[2].lower()))))
    f.close()

### this is used when we want grades of all students ###
if sys.argv[1] == "studentGrades" :

    gradesDict = grades(studentMarks,rollNumber)

    with open("studentsGrades.txt","w") as f:
        i = 0
        for keys in gradesDict.keys() :
            f.write(f"{keys},{name[i]},{gradesDict[keys]} \n ")
            i+=1

