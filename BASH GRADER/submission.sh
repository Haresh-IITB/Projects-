#!/usr/bin/env bash


#This is a upload function which extract path of file whose name is given in command line argument and copied to pwd
function upload() {
    file_name=$1
    path=$(find /home/ -name "$1" )
    mv $path $(pwd)
}

#This function have the set of if else which decides how do we need to merge the csv files
function toCombine() {
   
    local file_name=$1
    # rev command is used to reverse the string
    # column_name stores the name of the column we need to append in the header
    local column_name=$(echo "$file_name" | rev | cut -b 1-4 --complement | rev )

    # 1st if condition is useful if we pass file name via comand line arguments
    if [[ -f $file_name && $file_name != "main.csv" ]]; then 

        if [[ -f  "main.csv" ]]; then    ### do the following if main.csv exists ###             
                while read line 
                do
                    if [[ $line =~ ^[0-9]{2}[A-Za-z][0-9]* ]]; then          ### checking line is not header ###
                        roll_no=$(echo "$line" | cut -d"," -f 1)             ### extracting roll number from line ###
                        marks=$(grep -i "$roll_no" $file_name | cut -d"," -f 3 | tr -d "\r") ### extracting marks corresponding to the roll no from the file to be combined ###
                        line_req=$(grep -i "$roll_no" main.csv | tr -d "\r")    ### extracting line after which mark is to be appended ###
                    
                        ###  checking if he is present or not  ###  
                        if [[ $marks =~ [0-9]+ ]]; then  

                            ###now the below if else is to check if was present in any of the previous test or not ###
                            ###basically if does if was present then append the marks ###
                            ###or else first mark absent the number of times he was absent and then add his marks ###
                            
                            if [[ $line_req =~ ^[A-Za-z0-9] ]]; then                 
                                echo "$line_req,$marks" >> temp.csv
                            else
                                ### rn_name gives the roll number and name of the student ###
                                rn_name=$(echo "$line" | cut -d "," -f 1,2 | tr -d "\r" ) 
                                echo -n "$rn_name" >> temp.csv
                                absent_times=$(grep "Roll_Number" main.csv | cut -d "," -f 3- --output-delimiter=" "| wc -w)
                                for((count=0;count<$absent_times;count++))
                                do
                                    echo -n ",a" >> temp.csv
                                done
                                echo ",$marks" >> temp.csv
                            fi
                        fi
                    
                    #this is if line is an header as the variable name suggests :) 
                    else 
                        header_main=$(grep "Roll_Number" main.csv | tr -d "\r" )
                        header=$(echo "$header_main,$column_name")
                    fi
                done < $file_name

                
                ### below code is for marking absent of the student who has not attended file_name wala exam ###
                while read line
                do  
                    rollnum=$(echo "$line" | cut -d"," -f1 )
                    if [[ $line =~ ^[0-9]{2}[A-Za-z][0-9]* ]]; then         # checking line is not header   

                        ### below condition check if he is absent or not if he was absent that only if condition run otherwise it not runs ###
                        absent_check=$(grep -i "$rollnum" temp.csv)     

                        if [[ -z $absent_check ]]; then                     ### -z flag check whether string is empty or not if empty returns with exit status 0 i.e. True ###
                            lineModified=$(echo "$line" | tr -d "\r")
                            echo "$lineModified,a" >> temp.csv
                        fi
                    fi
                done < main.csv


                #rebuiliding main.csv 
                #first adding a header and then the remaining lines

                rm main.csv

                echo "$header" >> main.csv
                while read line
                do
                    line_modified=$(echo $line | tr -d "\r")
                    echo "$line_modified" >> main.csv
                done < temp.csv

                
                #deleting the temporary csv file once data is transferred

                rm temp.csv


        # this else is for when the main csv is not present
        else    
            while read line 
            do  
                if [[ $line =~ ^[0-9]{2}[A-Za-z][0-9]* ]]; then         # checking line is not header   #can change the regex to Roll and use the ! sign also to simplify code
                    lineModified=$(echo "$line" | tr -d "\r")
                    echo "$lineModified" >> temp.csv
                else    
                    echo "Roll_Number,Name,$column_name" > main.csv
                fi
            done < $file_name
            while read line
            do
                line_m=$(echo $line | tr -d "\r")
                echo "$line_m" >> main.csv
            done < temp.csv

            rm temp.csv
        fi 
    else    
        ### if argument provided file name not exist echo the following message
        echo "Usage : bash ./submission.sh <function-name> <files-name>(optional) "
    fi
}

#This function is used to combine all the csv files in pwd based on the command line argument provided
function combine() {
    check_total=0
    if [[ -f main.csv ]]; then
        a=$(grep "total" main.csv)
        if [[ ! -z $a ]]; then
            check_total=1
        fi
    fi
    if [[ $# == 1 ]] ; then
        if [[ -f main.csv ]];then 
        rm main.csv
        fi
        declare -a files=(*.csv)
        for((i=0;i<${#files[@]};i++))
        do
            toCombine ${files[$i]}
        done
        if [[ $check_total == 1 ]]; then
            bash ./submission.sh total
        fi
    else
        if [[ $check_total == 1 ]]; then
            awk -f remove_total.awk main.csv > temp.csv
            cat temp.csv > main.csv 
            rm temp.csv
        fi
        declare -a files=($@)
        unset files[0]
        for((i=1;i<=${#files[@]};i++))
        do
            toCombine ${files[$i]}
        done
        if [[ $check_total == 1 ]]; then
            bash ./submission.sh total
        fi   
    fi
}

#This function is used to update an existing entry
function update(){
    roll_number=""
    name=""
    ### Taking the roll number ###
    read -p "Enter the Roll Number of the student : " roll_number
    
    ############################ check if roll number is correct or not ##########################################

    ### Running the combine comannd to include all the rollnumber in main.csv
    if [[ ! -f "main.csv" ]]; then
        bash submission.sh combine
    fi
    
    a=$(grep -i "$roll_number" main.csv) 
    
    # a is a check if roll Number is correct or not if not then throws a error 
    if [[ -z $a ]]; then
        echo "The provided Roll Number is wrong"
        exit 0
    fi

    read -p "Enter the name of the student : " name

    c=$(grep -i -w "$roll_number,${name}," main.csv)
    ############################ check if pair of roll number and name is correct or not ##########################################
    if [[ -z $c ]]; then
        echo "Given name is not correct "
        echo "Did you mean"
        read -p "$(grep -i "$roll_number" main.csv | cut -d "," -f 2) [y/n]" answers
        if [[ $(echo $answers | tr [:upper:] [:lower:]) == n ]]; then
            exit 0
        else
            name=$(grep -i "$roll_number" main.csv | cut -d "," -f 2)
        fi
    fi

    ## if pair of Roll number and name is correct it iterates over all csv file and asks whether to update number or not ###
    if [[ ! -z $a ]]; then
        declare -a files=(*.csv)
        for((i=0;i<${#files[@]};i++))
        do
            if [[ ${files[i]} != "main.csv" ]]; then
                read -p "Enter the updated mark of student in $(echo ${files[i]} | rev | cut -b 1-4 --complement | rev) (If you want to not update the Entry just press Enter) : " marks
                if [[ ! -z $marks ]]; then
                    sed -i  "s/\($roll_number,${name}\).*/\1,$marks/I"  "${files[i]}"
                else
                    continue
                fi
            else
                continue
            fi
        done 
    fi

    ### Now will run the combine command to update the entries in the main.csv
    bash submission.sh combine
}

function update_customized(){
    #This function is used to update an existing entry
    ### Variables to store the values of rollNumber and name ###
    rollNumber=""
    name=""
   
    ### taking the name of the student ###
    read -p "Enter the name of the student : " name


    if [[ -z $name ]]; then
        echo "Usage : No input provided " 
        exit 0 
    else 
    ### checking is name is present in main.csv or not , if present find the roll number corresponding to it and if not then find the closest match name using python script stringMatch.py and ask user whether he wanted this name or not ###
    ### also checkpoint is intialised to ensure that take rollNumber from the name if and if that namw is present only once in the file elif ask the roll number ###
        c=$(grep -i -w "$name" main.csv)
        if [[ -z $c ]] ; then
            read -p "Did you mean $(python3 stringMatch.py "$name") [y/n] " check
            if [[ $(echo $check | tr [:upper:] [:lower:] ) == n ]]; then
                read -p "Please Enter the rollNumber of the student : " rollNumber
            else
                name="$(python3 stringMatch.py "$name")"
                if [[ $(grep -i -w "$name" main.csv | cut -d"," -f 1 | wc -w) == 1 ]]; then
                    rollNumber=$(grep -i -w "$name" main.csv | cut -d"," -f 1)  
                else
                    read -p "Please Enter the rollNumber of the student as more than one student has same name : " rollNumber
                fi
            fi
        else
            if [[ $(grep -i -w  "$name" main.csv | cut -d"," -f 1 | wc -w) == 1 ]]   ; then
                rollNumber=$(grep -i -w "$name" main.csv | cut -d"," -f 1)
            else 
                read -p "Please Enter the rollNumber of the student as more than one student has same name : " rollNumber
            fi
        fi
    fi

    
    ############################ check if roll number is correct or not ##########################################
    
    # # a is a check if roll Number is correct or not if not then throws a error 
    
    a=$(grep -i "$rollNumber" main.csv) 
    if [[ -z $a ]]; then
        echo "The provided Roll Number is wrong"
        exit 0
    fi

    ### iterating through all the csv files and asking whether to update the marks or not ####
    declare -a files=(*.csv)
    for((i=0;i<${#files[@]};i++))
    do
        if [[ ${files[i]} != "main.csv" ]]; then
            read -p "Enter the updated mark of student in $(echo ${files[i]} | rev | cut -b 1-4 --complement | rev) (If you want to not update the Entry just press Enter) : " marks
            if [[ ! -z $marks ]]; then
                sed -i  "s/\($rollNumber,${name}\).*/\1,$marks/I" "${files[i]}"
            else
                continue
            fi
        else
            continue
        fi
    done 

    ### Now will run the combine command to update the entries in the main.csv
    bash submission.sh combine
}

### This function is used to add a new entry to all csv files and then update that changes in main.csv
function addNewEntry(){
    ### asking the name and roll number of the new student ###
    read -p "Enter the Roll Number of the student : " roll_number

    read -p "Enter the name of the student : " name

    ### Iterating over all csv files and then add the entries of the student in that csv file
    declare -a files=(*.csv)
    for((i=0;i<${#files[@]};i++))
    do
        ### If the marks is given update it or else add "a" instead of it ###
        if [[ ${files[i]} != "main.csv" ]]; then
            read -p "Enter the mark of student in $(echo ${files[i]} | rev | cut -b 1-4 --complement | rev) (If student was absent then just press Enter) : " marks
            if [[ ! -z $marks ]]; then
                echo "$roll_number,$name,$marks" >> "${files[i]}"
            else
                echo "$roll_number,$name,a" >> "${files[i]}"
            fi
        else
            continue
        fi
    done
    ### adding that entries in main.csv also ###
    bash submission.sh combine
}

### Given a roll number of student it finds it entry in main.csv and display it for the given roll number using grep ### 
function studentDetail(){
    if [[ $# == 2 ]]; then
        rollnum="$2"
    else 
        rollnum="$1"
    fi
    grep -E "Roll_Number" main.csv > student.csv
    grep -E -i "$rollnum" main.csv >> student.csv
    if [[ "$1" == "reportCard" ]]; then
        sed -i "s/'a'/0/g" student.csv
    fi
}

function reportCard(){
    read -p "Enter the Roll Number for which you want to Generate the Report Card : " roll_no
    if [[ -z $(grep -i $roll_no main.csv) ]]; then
        echo "Wrong Roll Number"
        exit 0
    fi
    ### For our report card we need following
    # • IITB logo
    # • A csv which has the header of main.csv and the marks of the respective roll Number student (for latex a should be replaced by 0) , this is generated by the studentDetail
    # • A stats.csv generated by python file stats.py
    # • Two graph of percentile from reportcard.py
    # • gradestudent.txt from grades.py
    # • exam-wise-remarks.txt and Overall.txt generated from reportcard.py and grades.py
     
    python3 reportcard.py "reportCard" "$roll_no"

    python3 stats.py "reportCard"

    python3 grades.py "reportCard" "$roll_no"

    studentDetail  "reportCard" "$roll_no"

    pdflatex reportCard

    mv reportCard.pdf ${roll_no}_reportCard.pdf
    

}


### These if statements to cal the function based on the command line arguments ###

if [[ $1 == "combine" ]]; then
    combine $@
fi

if [[ $1 == "upload" ]]; then
    upload $2
fi

if [[ $1 == "total" ]]; then
    awk -f total.awk main.csv > temp.csv
    cat temp.csv > main.csv
    rm temp.csv
fi

if [[ $1 == "removeTotal" ]]; then
    awk -f remove_total.awk main.csv > temp.csv
    cat temp.csv > main.csv 
    rm temp.csv
fi

if [[ $1 == "update" ]]; then
    update
fi

if [[ $1 == "reportCard" ]]; then
    ### it check whether total is their or not and if not then first add and then remove after making
    ### the report Card
    check=$(grep -i "total" main.csv)
    if [[ -z $check ]]; then
        bash submission.sh total
    fi
    reportCard
    rm student.csv
    rm stats.csv
    rm gradeStudent.txt
    rm exam-wise-remarks.txt
    rm Overall.txt
    if [[ -z $check  ]]; then
        bash submission.sh removeTotal
    fi
    ### removing all the temporary files made for latex report ###
fi

if [[ $1 == "studentDetail" ]]; then
    read -p "Tell the student roll number : " rollNumber
    studentDetail "$rollNumber"
    cat student.csv 
    rm student.csv
    ### removing the temporary files made ###
fi

if [[ $1 == "studentGrades" ]]; then
    ### it check whether total is their or not and if not then first add and then remove after making
    ### the .txt file
    check=$(grep -i "total" main.csv)
    if [[ -z $check ]]; then
        bash submission.sh total
    fi
    python3 grades.py "studentGrades"
    cat studentsGrades.txt

    python3 plotcurveall.py "studentGrades"
    if [[ -z $check  ]]; then
        bash submission.sh removeTotal
    fi
fi

if [[ $1 == "addNewEntry" ]]; then
    addNewEntry
fi

if [[ $1 == "update_customized" ]]; then
    update_customized
fi

if [[ $1 == "stats" ]]; then

    ### it check whether total is their or not and if not then first add and then remove after making
    ### the stats file
    check=$(grep -i "total" main.csv)
    if [[ -z $check ]]; then
        bash submission.sh total
    fi
    python3 stats.py "statistics"
    mv stats.csv stats.txt
    if [[ -z $check  ]]; then
        bash submission.sh removeTotal
    fi
fi


