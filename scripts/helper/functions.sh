#!/bin/sh

check_container_up()
{
    # Take in container name
    # return 0 if good and 1 if bad
    container_name=$1

    if [[ $(docker inspect --format '{{json .State.Health.Status}}' $container_name) == "\"healthy\"" ]]; then
        return 0
    fi
    return 1
}

retry()
{
    local -i sleep_interval=5
    local -i max_time=$1; shift
    local -i current_time=0
    local -r cmd=$1; shift 
    local -r args="$@"

    until $cmd $args
    do
        if [[ "$current_time" -ge "$max_time" ]]; then
            echo "Error: Timed out on $cmd"
            return 1
        else
            printf "."
            current_time=$((current_time+sleep_interval))
            sleep $sleep_interval
        fi
    done
}
