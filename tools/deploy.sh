#!/bin/bash

# Downloads, builds and deploys a given version of probe-rs. Saves the previous installation
# which can be restored using tools/revert.sh

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
architectures=(
    "armv7"
    "armv7"
    "armv7"
    "armv7"
    "armv7"
    "aarch64"
    "aarch64"
    "aarch64"
)
probe_rs_rev="8cd15f5b787aeaa93c448a340d1c96613f158a87"

# unique values of architectures
declare -A targets
targets["armv7"]="armv7-unknown-linux-gnueabihf"
targets["aarch64"]="aarch64-unknown-linux-gnu"

file="probe-rs"

build_for_architecture () {
    target=$1
    if [ -f "${file}-${target}" ]; then
        return
    fi

    if [ ! -d "probe-rs" ]; then
        git clone git@github.com:probe-rs/probe-rs.git
    fi

    cd probe-rs
    git pull
    git checkout $probe_rs_rev

    triple=${targets[$target]}
    echo "Building ${file}-${target} (${triple})"
    cross build -p probe-rs-tools --release --target=$triple
    cp target/$triple/release/probe-rs ../$file-$target

    cd ..
}

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

for i in "${!runners[@]}"; do
    runner="${runners[$i]}"
    architecture="${architectures[$i]}"

    build_for_architecture $architecture

    echo "Deploying ${file}-${architecture} to ${runner}"
    scp "${file}-${architecture}" "${runner}:~/${file}"
    ssh "${runner}" "sudo chmod +x ~/${file}"
    ssh "${runner}" "sudo mv /home/espressif/.cargo/bin/${file} /home/espressif/.cargo/bin/${file}.backup"
    ssh "${runner}" "sudo mv ~/${file} /home/espressif/.cargo/bin/${file}"
done
