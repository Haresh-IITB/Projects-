BEGIN{
    FS=","
    OFS=","
}

{
    if($0 !~ "[0-9]{2}[A-Za-z][0-9]*"){
        print $0,"total"
    }    
    else{
        sum=0
        for (i=3;i<=NF;i++){
            if ($i == "a"){
                sum+=0
            }
            else{
            sum = sum + $i
            }
        }
        print $0,sum
    }
}
