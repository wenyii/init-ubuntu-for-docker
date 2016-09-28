#! /bin/bash

#path=~/init-ubuntu-for-docker
path=.

# source library and config
source ${path}/library.sh
iniFile="${path}/server.ini"

# parse params
debug=${1}
lang=${2-cn}

# change IFS
myIFS=';'
items=`keys ${iniFile} name.${lang} ${myIFS}`
_items=(`items ${iniFile}`)

standardIFS=$IFS
IFS=$myIFS

# show menu
items=($items)
menu "${items[*]}" "All of the server." "no" "" "yes"

IFS=$standardIFS
number=`inputint "Select server index" ${#items[*]} "" "yes"`

# show error when print menu
if [ "$?" != 0 ]
then
    echo -e "$number"
    exit
fi

number=(${number})
command=''

# perfect the command
function command()
{
    index=${1}

    item=${_items[`expr $index - 1`]}
    _cmd=`ini ${iniFile} ${item} cmd`

    # use nohup
    nohup=`ini ${iniFile} ${item} nohup`
    if [ "${nohup}" == "true" ]
    then
        _cmd="nohup $_cmd > /dev/null 2>&1"
    fi

    # fork process
    fork=`ini ${iniFile} ${item} fork`
    if [ "${fork}" == "true" ]
    then
        _cmd="$_cmd &"
    fi

    # need input
    input=`ini ${iniFile} ${item} input`
    if [ -n "${input}" ]
    then
        for var in ${input[*]}
        do
            default=`ini ${iniFile} ${item} default_${var}`
            result=$?

            prompt="Need input param \`$var\` for index $index"
            if [ -n "${default}" ]
            then
                prompt="$prompt [${default}]"
            fi

            read -p "$prompt : " param

            if [ -z "${param}" ]
            then
                if [ "${result}" != "0" -a -z "${default}" ]
                then
                    color 31 "The param \`$var\` for index $index required." "\n" "\n\a"
                    exit 1
                fi
                param=$default
            fi

            eval $var=$param
        done

        eval echo "$_cmd"
    else
        echo "$_cmd"
    fi
}

# multiple command
if [ ${#number[*]} -gt 1 ]
then
    read -p "You want execution by sync/async ? [async] : " mode

    if [ -z "${mode}" -o `inarray sync async $mode` == "no" ]
    then
        mode="async"
    fi

    for num in ${number[*]}
    do
        cmd=`command $num`
        if [ "$?" != "0" ]
        then
            echo "$command"
            exit 1
        fi

        # exec mode
        if [ "${mode}" == "sync" ]
        then
            operation="&&"
        else
            operation=";"
        fi

        command="${command} ${operation} ${cmd}"
    done

    command=${command:`expr ${#operation} + 2`}
else
    # only a command
    command=`command ${number[0]}`
    if [ "$?" != "0" ]
    then
        echo "$command"
        exit 1
    fi
fi

# print the command when debug
if [ -n "${debug}" -a "${debug}" == "debug" ]
then
    color 30 "$command" "\n" "\n"
else
    eval $command
    color 32 "Command execution completed." "\n" "\n"
fi

# -- eof --