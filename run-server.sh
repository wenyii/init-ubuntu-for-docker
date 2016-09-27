#! /bin/bash

source ./library.sh

iniFile='./server.ini'
debug=${1}
lang=${2-cn}

myIFS=';'
items=`keys ${iniFile} name.${lang} ${myIFS}`
_items=(`items ${iniFile}`)

standardIFS=$IFS
IFS=$myIFS

items=($items)
menu "${items[*]}" "All of the server." "yes" "" "yes"

IFS=$standardIFS
number=`inputint "Select server index" ${#items[*]} "" "yes"`

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

    nohup=`ini ${iniFile} ${item} nohup`
    if [ "${nohup}" == "true" ]
    then
        _cmd="nohup $_cmd > /dev/null 2>&1"
    fi

    fork=`ini ${iniFile} ${item} fork`
    if [ "${fork}" == "true" ]
    then
        _cmd="$_cmd &"
    fi

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
                    color 31 "The param \`$var\` for index $index required." "" "\a"
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
    command=`command ${number[0]}`
fi

if [ -n "${debug}" -a "${debug}" == "debug" ]
then
    color 30 "$command" "\n" "\n"
else
    eval $command
    color 32 "Command execution completed." "\n" "\n"
fi