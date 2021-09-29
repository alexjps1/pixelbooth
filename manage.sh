if [ "$1" == "-m" ] ;
then
    rm workspace/* &> /dev/null
    mkdir ${2}/$(date +"%Y-%m-%d-%H-%M-%S")-archive &> /dev/null
    cp -r archive/* ${2}/$(date +"%Y-%m-%d-%H-%M-%S")-archive &> /dev/null
    rm archive/images/* &> /dev/null
    rm archive/receipts/* &> /dev/null
    rm archive/not-uploaded/* &> /dev/null
    echo Moved archived data to ${2}/$(date +"%Y-%m-%d-%H-%M-%S")
elif [ "$1" == "-c" ]
then
    rm workspace/* &> /dev/null
    mkdir ${2}/$(date +"%Y-%m-%d-%H-%M-%S")-archive &> /dev/null
    cp -r archive/* ${2}/$(date +"%Y-%m-%d-%H-%M-%S")-archive &> /dev/null
    echo Copied archived data to ${2}/$(date +"%Y-%m-%d-%H-%M-%S")
elif [ "$1" == "-d" ]
then
    rm workspace/* &> /dev/null
    rm archive/images/* &> /dev/null
    rm archive/receipts/* &> /dev/null
    rm archive/not-uploaded/* &> /dev/null
    echo Deleted archived data
else
    echo "--help          Overwiew of commands"
    echo "-m <path>       Move archive data to given path"
    echo "-c <path>       Copy archive data to given path"
    echo "-d              Outright delete archive data"
fi