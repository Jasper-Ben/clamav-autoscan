#!/bin/bash

# Prepare log pipes
mkdir -p /var/log/clamav
touch /var/log/clamav/clamd.log /var/log/clamav/freshclam.log
chown -R clamav:clamav /var/log/clamav/
chown root:tty /dev/console
chmod g+rw /dev/console

BACKGROUND_TASKS=()

(
while true; do
    sleep 1m
    freshclam
    sleep 1h
done
) &
BACKGROUND_TASKS+=($!)

clamd &
BACKGROUND_TASKS+=($!)

(
    inotifywait --quiet --monitor --event close_write,moved_to --recursive --format '%w%f' /data | while read FILE
    do
    	# Have to check file length is nonzero otherwise commands may be repeated
     	if [ -s "$FILE" ]; then
            if clamdscan -vm "$FILE"; then
                mv "$FILE" /clean/
            else
                mv "$FILE" /infected/
            fi
        fi
    done
) &
BACKGROUND_TASKS+=($!)

while true; do
    for bg_task in ${BACKGROUND_TASKS[*]}; do
        if ! kill -0 ${bg_task} 1>&2; then
        echo "Worker ${bg_task} died, stopping container waiting for respawn..."
        kill -TERM 1
        fi
        sleep 10
    done
done
