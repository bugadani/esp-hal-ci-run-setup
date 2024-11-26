#!/bin/bash

runners=(
    "br.BrnoRPIRS01"
    "br.BrnoRPIRS02"
    "br.BrnoRPIRS03"
    "br.BrnoRPIRS04"
    "br.BrnoRPIRS05"
    "br.BrnoRPIRS06"
    "br.BrnoRPIRS07"
    "br.BrnoRPIRS08"
)

# Parse optional CLI argument
if [ $1 ]; then
    # find the index of the specified runner
    found=0
    for i in "${!runners[@]}"; do
        if [ "${runners[$i]}" == $1 ]; then
            runners=($1)
            architectures=(${architectures[$i]})
            found=1
            break
        fi
    done

    if [ $found -eq 0 ]; then
        echo "Runner $1 not found"
        exit 1
    fi
fi

file="probe-rs"

for i in "${!runners[@]}"; do
    runner="${runners[$i]}"

    echo "Reverting ${runner}"
    ssh "${runner}" "sudo mv /home/espressif/.cargo/bin/${file}.backup /home/espressif/.cargo/bin/${file}"
done
