#!/usr/bin/env bash


### This is used to intialise a remote repository
function git_init(){

    ### $1 is the path of the remote repo location ###
    directory_name=$1

    ### Below if states that if remote repo directory not exist make it ###
    if [[ ! -d $directory_name ]]; then 
        mkdir "$directory_name"
    fi
    
}


### This function is used for commit the current working directory with a commit message
function git_commit(){

    ### Commit message stores the commit message and commit id stores the commit id ###
    commit_message="$1"
    commit_id=''

    ### This for loop is used to generate a random 16 digit numbemr ###
    for((i=0;i<16;i++))
    do
        ### shuf is a inbuilt function to generate a random number and -i flag is to specify range and -n is used to specify number of random number generated in this case 1 ###
        rand=$(shuf -i 0-9 -n 1)
        commit_id+=$rand 
    done

    ### Dir name stores the dir name of the form <comit-id>:<commit message> ###
    ### I am making a directory in the git_init specified directory with name of dir_name and this directory stores the cp of commited state of the original directory ###
    dir_name=$commit_id
    dir_name+=":$commit_message"
    mkdir "$rrl/$dir_name"
    cp -r ./. "$rrl/$dir_name/."
    if [[ $? == 0 ]]; then
        echo "commit message : $commit_message"
        echo -e "\n"
        if [[ -f .git_log.txt ]];then
            last_commit=$(ls -t "$rrl/." | head -2 | tail -1 )
            filesAdded=$(diff -rq -B . "$rrl/$last_commit/." | grep "^Only" | cut -b 1-11 --complement )
            filesChanged=$(diff -rq -B . "$rrl/$last_commit/." | grep "^Files" | awk '{print $2}')
            if [[ -z $filesAdded ]]; then
                echo "No files are added"
                echo -e "\n"  
            else
                echo "Files Added : "
                echo "$filesAdded" 
                echo -e "\n"
            fi

            if [[ -z $filesChanged ]]; then
                echo "No files are modified"
                echo -e "\n"  
            else
                echo "Files Modified : "
                echo "$filesChanged " 
                echo -e "\n"
            fi
        fi
        echo -n "$commit_id   " >> .git_log.txt
        echo  "$commit_message" >> .git_log.txt
    else
        rm -r "$rrl/$dir_name"
    fi

}

function git_checkout(){
    ### TBM means to be matched it is either commit-id or the commit-message ###
    TBM=$1
    flag="$2"

    ### FREQUENCY check whether or not the matched commit with the provided message is 1 or more ###
    ### dir_name stores the name of the commit we want to checkout ###
    frequency=$(ls "$rrl" | grep "$TBM" | wc -l)
    dir_name="$(ls "$rrl" | grep "$TBM")"

    if [[ $frequency == 1 ]] ; then

        if [[ ! -d "$rrl/master" ]]; then
            mkdir "$rrl/master/"
            cp -r ./. "$rrl/master/."
        fi


        ### copying all the file of that commit to pwd ###
        if [[ "master" == $dir_name ]]; then
            echo "Switching Back to master"
            cp -r "$rrl/$dir_name/." "$(pwd)/."
            rm -r "$rrl/master"
        else
            echo "Switching The HEAD to $(echo $dir_name | cut -b 1-16) "
            cp -r "$rrl/$dir_name/." "$(pwd)/."
        fi
            
    ### these are to return error like wring id / or insufficient legth of the i or message ###
    elif [[ $frequency == 0 ]] ; then
        if [[ $flag == "-m" ]]; then
            echo "Wrong commit-message provided"
        else
            echo "Wrong commit-id provided"
        fi
    else
        echo "TOO less characters provided to match please provide more characters"
    fi

}

function git_log(){
    n=$(cat ".git_log.txt" | wc -l)
    for((i=1; i <= $n ;i++))
    do  
        echo -n "Commit - id ---->"
        if [[ $i == 1 ]]; then
            echo "$(cat .git_log.txt | tail -$i | head -1 |cut -b 1-16) *****(HEAD)****"
        else
            cat .git_log.txt | tail -$i | head -1 |cut -b 1-16
        fi
        echo -n "Commit - message ---->"
        cat .git_log.txt | tail -$i | head -1 |cut -b 1-17 --complement
        echo -e "\n"
    done
}

### "Remote repo location : rrl " ###
rrl=''                                

if [[ $1 == "git_init" && $# == 2 ]]; then

    ### status is like a counter which check whether or not rrl.txt is present or not , means it check this is the first time you are tunning git_init , if yes then it's value is 0 or else 1 ###
    status=0
    answer=""

    ### This if loop check whether or not rrl.txt exists or not . If it does then take the location of the current rrl(remote repo location) from rrl.txt ans store it in the global variable rrl also , user is asked whether ot not he wants to make a new repo or just to keep the old repo ###
    if [[ -f rrl.txt ]]; then
       
       ### reading rrl.txt to get the value of rrl
        while read line 
            do
                rrl=$line
            done < rrl.txt
        rm rrl.txt
       ### status = 1 implies that a rrl already exists
        status=1
        echo "A remote repository already exists"
        read -p "Do want to make a new remote repository? [y/n] " answer
    fi

    if [[ -f .git_log.txt ]]; then
        rm .git_log.txt
    fi
    
    if [[ $status == 1 ]]; then

        ### using tr to make input case insensitive ###
        ### if user says yes then copying all the data from previous rrl to new rrl and deleting the old rrl ###
        if [[ $(echo $answer | tr [:upper:] [:lower:]) == y ]]; then
            read -p "Do you want to copy the data from Old repo [y/n]" ans
            if [[ $(echo $ans | tr [:upper:] [:lower:] ) == y ]]; then
                    
                echo "Copying the data from old repository to new Repository .... "
                
                cp -r "$rrl"/. "$2"
                rm -r "$rrl"
                
                ### writing the location of new repo in the rrl.txt
                echo "$2" > rrl.txt
            else 
                git_init "$2"
                rm -r "$rrl"
                echo "$2" >> rrl.txt
            fi
                
        elif [[ $(echo $answer | tr [:upper:] [:lower:]) == n ]]; then
        
            echo "Remote repository remains the same"
            
            ### writing the rrl as previous location only ###
            echo "$rrl" > rrl.txt
            exit 0

        fi
    
    ### This else is executed if the git_init is being run for the first time ###
    else 
        git_init "$2"
        echo "$2" > rrl.txt
    fi    
fi

if [[ $1 == "git_init" && $# != 2 ]]; then
    echo "Usage : bash ./submission.sh git_init <remote-repo-path>"
fi


### this is if-else check whether or not git repo is initiallised or not and make a rrl.txt which stores the location of rrl.txt

if [[ -f rrl.txt ]]; then
    while read line 
    do
        rrl=$line
    done < rrl.txt
else
    echo "Usage : First initialize a git repository using git_init " 
    exit 
fi


### This if for calling git_commit  ###
if [[ $1 == "git_commit" && $2 == "-m" && $# == 3 ]]; then
    git_commit "$3"
fi

### This throws error if the git_commit is not called correctly
if [[ $1 == "git_commit" && $# != 3 ]]; then
    echo "Usage : bash ./submission.sh git_commit -m \"<commit-message>\" "
fi


### This if for calling git_checkout  ###
if [[ $1 == "git_checkout" && $# == 2 ]]; then
    if [[ $2 =~ [0-9]+ ]]; then
        git_checkout "$2"
    else
        echo "Usage : bash ./submission.sh git_checkout \"<commit-id>\""
    fi
fi

if [[ $1 == "git_checkout" && $2 == "-m" && $# == 3 ]]; then
    git_checkout "$3" "$2"
elif [[ $1 == "git_checkout" && $2 != "-m" && $# == 3 ]]; then
    echo "Usage : bash ./submission.sh git_checkout -m \"<commit-message>\" "
fi

### This check if whether or not the git_checkout is called correctly or not ###
if [[ $1 == "git_checkout" && ($# != 2 && $# != 3) ]]; then
    echo -n "Usage : bash ./submission.sh git_checkout \"<commit-id>\" OR "
    echo "Usage : bash ./submission.sh git_checkout -m \"<commit-message>\"  "
fi

if [[ $1 == "git_log" ]]; then
    git_log 
fi