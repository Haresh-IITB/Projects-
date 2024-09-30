BEGIN{
    FS=","
    OFS=""
}

{
        i=1
        while(i<NF-1){
        printf "%s,",$i
        i = i + 1
        }
        if( i == NF-1){
            printf "%s\n",$i
        }
}