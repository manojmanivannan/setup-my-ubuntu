#!/bin/bash

#####################################
#####################################
# Author: Manoj Manivannan
#####################################
#####################################

usage()
{
cat << EOF

usage of :$0

This script will run one or more pcaps at a given speed in a loop for l number of times.
Then sleep for t seconds between each pcap. 
script also logs the timestamp + filenames of pcaps injected to traffic.log in current directory.

OPTIONS:
        -f      filename(s) 
                example: -f file1.pcap file2.pcap
        -d      directory [inject all .pcap files from a directory]
        -m      monitor for files under directory used in -d
        -l      number of loops ( use 0 for infinite loop )
        -t      timer - seconds to wait
        -s      Speed type (normal, topspeed)
        -x      Kill any current traffic inject
        -r      pattern(s) matching file name will be injected at normal speed
                example: -r voice -r rtcp  [case insensitive]
        -p      expire inject queue if it took longer than p seconds (default 3600 seconds)
        -g      Show history of injected pcap logs
        -h      print this help and exit

Example:
$0 -f /full/path/filename1.pcap -l 2 -t 2 -s topspeed                           (1 file)
$0 -f /full/path/filename2.pcap /full/path/filename3 -l 2 -t 2 -s topspeed      (2 or more files)
$0 -f \$(find /folder/path \( -name "130*.pcap" -o -iname "dia*" \))            (match multiple patterns)
$0 -f \$(find /folder/path -name '*regex*.pcap') -l 2 -t 2 -s topspeed -r Voice (all files in folder [with regex])
$0 -d /folder/path -l 2 -t 2 -s topspeed -r Voice                               (all files in folder [with regex])
$0 -d /folder/path -f /full/path/filename2.pcap -l 2 -t 2 -s topspeed -r Voice  (all files in folder + additional files)
$0 -d /folder/path -m -l 2 -t 2 -s topspeed -r Voice                            (all files in folder [with regex] and monitor for files)
EOF
}

red=$'\e[0;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[0;35m'
cyn=$'\e[0;36m'
end=$'\e[0m'

inj_kill=0
timer_expire=3600
MONITOR=0
SHOW_LOG=0
monitor_enabled=disabled

while getopts "hf:d:ml:t:s:xr:p:g" opt
do
        case $opt in
                h ) usage
                        exit 1
                        ;;
                f ) files_input=("$OPTARG")
                    until [[ $(eval "echo \${$OPTIND}") =~ ^-.* ]] || [ -z $(eval "echo \${$OPTIND}") ]; do
                        files_input+=($(eval "echo \${$OPTIND}"))
                        OPTIND=$((OPTIND + 1))
                    done
                    ;;
                d ) directory=$OPTARG;;
                m ) MONITOR=1;monitor_enabled=enabled;;
                l ) loops=$OPTARG;;
                t ) timer=$OPTARG;;
                s ) speedtype=$OPTARG;;
                x ) inj_kill=1;;
                r ) file_regex+=("$OPTARG");;
                p ) timer_expire=$OPTARG;;
                g ) SHOW_LOG=1;;
                ? ) usage
                        exit;;
        esac
done

inject_stop(){

        curl -s --request POST --header "Content-Type: application/json" --data '{ "command": "Inject '"stop"\"' }' localhost:5010/v1/shellmgr
}

function promptFile(){
        local MESSAGE="$1"
        while true;
            do
                    read -p "$MESSAGE" log_file

                    if [ ! -f $log_file ]; then
                        echo "File does not exist, please try again" >&2
                    else
                        echo $log_file
                        break
                    fi
            done
}

get_files_from_directory(){
        local DIRECTORY=$1
        local my_list=()
        if ! [[( -z $files_input)]] 
        then
                files_dir=$(find $DIRECTORY -name '*.pcap')
                my_list=(${files_input[@]} ${files_dir[@]})
                # echo "files_input ${files_input[@]}"
                # echo "my_list ${my_list[@]}"
        else
                # echo "my_list"
                my_list=($(find $DIRECTORY -name '*.pcap'))
        fi
        my_list=($(printf "%s\n" "${my_list[@]}" | sort -u)) # get unique files
        echo "${my_list[@]}"
}

if [ "$inj_kill" -eq 1 ];
then
        OUTPUT=$(inject_stop)
        printf "${red}$OUTPUT\n${end}"
        exit 1
fi

if [ "$SHOW_LOG" -eq 1 ];
then
        LOG_FILE="traffic.log"
        if [ ! -f "$LOG_FILE" ];
        then
                echo "Log file $LOG_FILE not found"
                LOG_FILE=$(promptFile "Please Enter log file location (ex: /pcaps/traffic.log): ")
                echo "Logs from $LOG_FILE"
        fi

        tail $LOG_FILE
        exit 0

fi


if [[( -z $files_input) && ( -z $directory)]]   # if the filename flag receives blank, then raise error
        then
                printf "${red}No files/directory specified${end}\n"
                usage
                exit 1
fi

if ! [[( -z $directory)]]   # if Directory is given
then
    files=($(get_files_from_directory $directory))
else
    files=(${files_input[@]})
fi


if [[ ( -z $directory) && ($MONITOR -eq 1) ]]
then
    printf "${red}Can not monitor without specifying directory${end}\n"
    usage
    exit 1
fi

if [[( -z $speedtype)]]
        then
                speedtype="normal"
fi

if [[($timer == "") || ($loops == "")]]   # if timer/loop is empty, then raise error
        then
                echo "
                No timer/snooze specified"
                usage
                exit 1
fi

if ! [[ ($loops =~ ^[0-9]+$) ]]   #if timer/loop is not a number, then raise error
        then
                echo "
                Integer only for timer/snooze"
                usage
                exit 1
fi


######################################################################################################

function no_ctrlc()
{
    local master_end_time_sec=$SECONDS
    local duration
    local hours
    local seconds
    duration=$((master_end_time_sec-master_start_time_sec))
    hours=$(($duration / 3600))
    minutes=$((($duration / 60) - (60 * hours)))
    seconds=$(($duration % 60))
    echo
    echo "-------------------------------------------------------"
    printf "Script completed in ${grn}%s hours %s minutes %s seconds${end}\n" "$hours" "$minutes" "$seconds"
    echo "-------------------------------------------------------"
    exit
}

trap no_ctrlc SIGINT
######################################################################################################
wait_time="5"
is_inject_in_progress()
{
local active=$(curl --request POST -s --header "Content-Type: application/json" --data '{ "command": "showstats" }' localhost:5010/v1/shellmgr | grep 'Load/Inject Active:' | awk '{print $3}')

if [ -z "$active" ]; then
        return 1  # active is empty, no pcap playing. return 1 mean false
else
        return 0  # active is non-empty, pcap is playing, return 0 means true
fi

}

longest_string()
{
local mystring=$@
local m=-1
for x in ${mystring[@]}
do
        x=$(basename $x)
        if [ ${#x} -gt $m ]
        then
                m=${#x}
        fi
done
echo "$m"
}


echo ""

printerr()
{
local msg=$1
printf "${red}$msg${end}\n"
echo "$msg" >> traffic.log
}

function if_fail_exit()
{
local OUTPUT=$1
local FILE_NAME=$2
#hmshellmgr capture inject "$file_full_path" "$speedtype" > /dev/null 2>&1
if [[ "$OUTPUT" == *"Inject failed"* ]]; then
        printerr "Playback failed for $FILE_NAME: Msg: $OUTPUT"
        #exit 2
fi
}

function wait_for()
{
    local SEC="$1"
    local count=$SEC

        chars="/-\|"
    sleep $SEC & PID=$!

    printf " sleeping   "
    while kill -0 $PID 2> /dev/null;do
        for ((i=0;i<${#chars};i++));do
                printf "\b\b\b${yel} ${chars:$i:1} ${end}"
                sleep 0.1
        done
    done
    printf "\b\b\b\b\b\b\b\b\b\b\b"

}


ifMatch(){
  local file_name=$1; shift
  local array_of_regex="$@"
  [[ ${#array_of_regex[@]} -eq 0 ]] && return 1
  for each_regex in ${array_of_regex[@]}
  do [[ ${file_name,,} =~ ${each_regex,,} ]] && return 0; done
  return 1
}


padlength=$(longest_string "${files[@]}")
pad=$(printf '%0.1s' "-"{1..100})

if [ "$loops" -eq 0 ]; then loops="oo"; fi

printf "${grn}Loop %b time(s); sleep %s second after each pcap; Traffic inject at speed: %s; Normal speed for files matching (%s); Expire timeout %s; Monitoring %s for %s ${end} (updates in the next loop)\n\n;" "$loops" "$timer" "$speedtype" "${file_regex[*]}" "$timer_expire" "$monitor_enabled" "$directory" | tee -a traffic.log

SECONDS=0
master_start_time_sec=$SECONDS
loop_count=1
old_file_name=""
file_name=""
while true;
        do
        file_count=1
        if [[( $MONITOR -eq 1) && ! ( -z $directory)]]
        then
            files=($(get_files_from_directory $directory))
            padlength=$(longest_string "${files[@]}")
            pad=$(printf '%0.1s' "-"{1..100})
        fi
        for file in "${files[@]}"
                do
                file_full_path=$(realpath $file)
                old_file_name=${file_name:=$(basename $file)}
                file_name="$(basename $file)"
                loop_start_time=$SECONDS

                if ifMatch $file_name ${file_regex[@]}; 
                then
                        modified_speed_type=" normal "
                else
                        if [[ ! $speedtype == "normal" ]]; then modified_speed_type="topspeed"; else modified_speed_type=" normal "; fi
                fi 

                while is_inject_in_progress; do
                        sleep "$wait_time"
                        printf "${yel}(%s)${end}; Waiting to inject ${cyn}$file_name${end}. Elapsed ${yel}$((SECONDS-loop_start_time))${end} seconds\r" "$(date +"%Y-%b-%d %T")"
                        if [[ $((SECONDS-loop_start_time)) -ge $timer_expire ]]; then
                                printf "\n${yel}(%s)${end}; ${red}%s${end} took longer than ${yel}%s${end} seconds waiting." "$(date +"%Y-%b-%d %T")" "$old_file_name" "$timer_expire" 
                                echo "$(date +"%Y-%b-%d %T"); $old_file_name took longer than $timer_expire seconds waiting. Stopped." >> traffic.log
                                inject_stop
                        fi
                done
                OUTPUT="$(curl -s --request POST --header "Content-Type: application/json" --data '{ "command": "Inject '"${file_full_path} ${modified_speed_type}"\"' }' localhost:5010/v1/shellmgr)"

                echo "$(date +"%Y-%b-%d %T"); $OUTPUT" >> traffic.log
                if_fail_exit "$OUTPUT" "$file_full_path"

                printf "\r${yel}(%s)${end}; Loop:${grn}%2.2s${end} of ${blu}%b${end}; File:${grn}%3.3s${end} of ${blu}%s${end} for ${cyn}%s${end} (%s)" \
                        "$(date +"%Y-%b-%d %T")"       "$loop_count"              "$loops"           "$file_count"      "${#files[@]}"   "${file_name}" "${modified_speed_type}" | tee -a traffic.log
                printf "${red}%*.*s${end}" 0 $((padlength - ${#file_name} +1 )) "$pad"
                wait_for "$timer"


                loop_end_time=$SECONDS
                printf " Elapsed ${yel}%4.4s${end} seconds\n" \
                                "$(($loop_end_time-$loop_start_time))"
                file_count=$((file_count+1))

        done
        if [ "$loops" == "$loop_count" ];then
                break
        fi
        loop_count=$((loop_count+1))
done
master_end_time_sec=$SECONDS
duration=$((master_end_time_sec-master_start_time_sec))
hours=$(($duration / 3600))
minutes=$((($duration / 60) - (60 * hours)))
seconds=$(($duration % 60))
echo "\n" >> traffic.log
echo "-------------------------------------------------------"
printf "Playback completed in ${grn}%s hours %s minutes %s seconds${end}\n" "$hours" "$minutes" "$seconds"
echo "-------------------------------------------------------"

