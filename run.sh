#!/bin/sh

MAX_PROCS=3
BOXES=(leviathan2 leviathan3)

parallel_provision() {
    for box in ${BOXES[*]}; do
        echo "Provisioning '$box'. Output will be in: $box.out.txt" 1>&2
        echo $box
    done | xargs -P $MAX_PROCS -I"BOXNAME" \
                 sh -c 'vagrant provision BOXNAME >BOXNAME.out.txt 2>&1 || echo "Error Occurred: BOXNAME"'
}

echo "==> Booting up the boxees and provisioning leviathan1 ..."
vagrant up leviathan1
vagrant up --no-provision

echo "==> Provisioning the rest of the boxes..."
parallel_provision
