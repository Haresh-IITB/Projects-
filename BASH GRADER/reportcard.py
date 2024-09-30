import numpy as np
import matplotlib.pyplot as plt
import grades
import sys

### This  function gives the percentile of a student for a given marks ###
### It takes 3 arguments a numpy array of all rollnumber , the rollnumber of the student you want to find percentile of and the marks which is nothing but studentMarks i.e. a 2D array of exam marks and roll number ###
def PercentileStudent(marks,rollNumber,rollNumberStudent) :
    i = 0
    marks_percentile_student=[]
    while(i<marks.shape[1]) :
        ### The below list contain percentile of exam ###
        ### it is given by sum of all marks less than  or equal to the students marks and divide it by number of students , then multiply by 100
        marks_percentile_student.append(np.sum(marks[...,i]<=marks[np.where(rollNumber == rollNumberStudent),i])/len(marks[...,i])*100)
        i=i+1   
    return marks_percentile_student


### This things generates 2 plots of a given student ###
def reportCard(studentMarks,rollNumber,rollNumberStudent,examName,name):
    ### y is the percentile of the student ###
    y = PercentileStudent(studentMarks,rollNumber,rollNumberStudent)
    ### It is ticks of the number of exam corresponding to exam name ###
    x = np.arange(1,len(examName)+1)
    ### This represents a colour mapping done on based of percentile of the student in various exams ###
    colors = []
    for per in y :
        if per >= 98:
            colors.append("darkgreen")
        elif per >= 90:
            colors.append("palegreen")
        elif per >= 75:
            colors.append("lightblue")
        elif per >= 50:
            colors.append("blue")
        elif per >= 30:
            colors.append("violet")
        elif per >= 20:
            colors.append("mediumpurple")
        elif per >= 10:
            colors.append("orange")
        elif per >= 5:
            colors.append("red")
        else:
            colors.append("red") 
    ### it is used to set the size of the figure ###
    plt.figure(figsize=(8, 6))
    ### Plotting a bar graph ###
    plt.bar(x,y, color=colors)
    ### Xticks is used to label the x axis with exam names 
    plt.xticks(np.arange(1,len(examName)+1),examName)
    plt.xlabel('Exams')
    plt.ylabel('Percentile Scored')
    plt.title('Percentile Scored in Various Exams')
    ### yticks is used to mark from 0 to 100 in an interval of 10 ###
    plt.yticks(np.arange(0,101,10))
    ### It makes a grid 
    plt.grid(axis='y', linestyle='--', alpha=0.7)  # Add a grid for better readabiliy
    # Custom legend 
    legend_labels = [
        '>=98',
        '>=90',
        '>=75',
        '>=50',
        '>=30',
        '>=20',
        '>=10',
        '>=5',
        '<5'
    ]
    # name for the custom legends
    legend_colors = [
        'darkgreen',
        'palegreen',
        'lightblue',
        'darkblue',
        'violet',
        'mediumpurple',
        'orange',
        'red',
        'darkred'
    ]
    ''' (0, 0): This specifies the bottom-left corner of the rectangle.
        1: This specifies the width of the rectangle.
        1: This specifies the height of the rectangle.
        color=color: This specifies the color of the rectangle. The color variable is being iterated over a list called legend_colors '''
    legend_patches = [plt.Rectangle((0, 0), 1, 1, color=color) for color in legend_colors]
    '''By adjusting the bbox_to_anchor parameter, you can control the exact placement of the legend 
    relative to the plot. In your example, (1.15, 1) would mean that the legend will be placed to the 
    right of the plot (beyond its right border) and slightly above the upper border'''
    plt.legend(legend_patches, legend_labels, loc='upper right',bbox_to_anchor=(1.15, 1))
    # ********************************************************************
    '''Explanation for tranform and (0.99, 1) are relative to the axes of the plot, rather than being data 
    coordinates. plt.gca() gets
      the current Axes instance, and transAxes is a coordinate transformation that transforms the 
      coordinates to a normalized coordinate system where (0,0) is the bottom-left of the axes and (1,1)
        is the top-right. This normalization allows the text to be positioned relative to the axes rather
        than the data.'''
    #*********************************************************************
    plt.text(0.99, 1, 'Percentile', fontsize=12, ha='left', va='bottom', transform=plt.gca().transAxes)
    nameStudent=name[np.where(rollNumber == rollNumberStudent)]
    # plt.show()
    plt.savefig("barGraph")
 
    #line plot#
    plt.figure(figsize=(8, 6))
    plt.plot(x, y, marker='o', color='black', markersize=8, markerfacecolor="red", markeredgewidth=1.5, linestyle='-')
    # Additional plot configurations
    plt.xticks(np.arange(1, len(examName) + 1), examName)
    plt.xlabel('Exams')
    plt.ylabel('Percentile Scored')
    plt.title('Percentile Scored in Various Exams')
    plt.yticks(np.arange(0, 101, 10))
    
    # Save the figure
    plt.savefig("lineGraph")
    
    # Show the plot
    # plt.show()

### this function is used to give remarks based on the percentile of the student for the all the exams ###
def remarks_exam(percentile) :
    if percentile >= 98:
        return "Exceptional performance! Congratulations on achieving the highest percentile. Keep up the outstanding work."
    elif 90 <= percentile < 98:
        return "Excellent work! Your performance places you in the top tier of the class. Keep striving for excellence."
    elif 75 <= percentile < 90:
        return "Very good job! Your performance is above average and demonstrates a strong understanding of the material."
    elif 50 <= percentile < 75:
        return "Good effort! You're performing at a satisfactory level and showing understanding of the subject matter."
    elif 30 <= percentile < 50:
        return "Fair performance. There's room for improvement, but you're making progress. Keep working hard."
    elif 20 <= percentile < 30:
        return "Below average performance. It's important to focus on areas that need improvement and seek help if necessary."
    elif 10 <= percentile < 20:
        return "Needs improvement. Your performance indicates some difficulties understanding the material. Extra effort and attention are needed."
    elif 5 <= percentile < 10:
        return "Poor performance. Immediate action is necessary to address the challenges you're facing. Seek assistance and put in extra effort."
    else :
        return "Fail. Your performance falls below the minimum standard required for passing. Remedial action is crucial to improve your understanding and performance."


rollNumber = np.char.lower(np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,0])
name = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,1]
examName = np.loadtxt("main.csv",delimiter="," ,dtype=str)[0,2:]
marks = np.loadtxt("main.csv",delimiter="," ,dtype=str)[1:,2:]
marks_upd = np.where(marks == "a", "0" , marks)
studentMarks = marks_upd.astype(float)

### this piece of code is used to accept the bash argument ###
if sys.argv[1] == "reportCard" :
    with open("exam-wise-remarks.txt","w") as f :
        for i in range((len(examName))-1) :
            f.write(f"{examName[i]} : {remarks_exam(PercentileStudent(studentMarks,rollNumber,sys.argv[2].lower())[i])}\n\n")
    reportCard(studentMarks,rollNumber,sys.argv[2].lower(),examName,name)
