#!/bin/bash

##############################################################
## Thank you very much for your support! It's very impotant!##
##							    ##
## Nicehash donate: 3JKA47P98c9JGCy3GN7qXFC2FzeuJmXuph	    ##
## Zec donate: t1fP9jWyqFEni2p4i9t3byqtimsMKv1y95T          ##
## ETH donate: 0xe835a7d5605a370e4750279b28f9ce0926061ea2   ##
##############################################################

DELAY=30
MIN_SPEED=20
MIN_TEMP=60
MAX_TEMP=70
MIN_COEF=80
MAX_COEF=110

VERSION="2.0"
s_name="autofan.sh"
export DISPLAY=:0

red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)

function set_var {
read -p  "Enter DELAY (default 30): "
if [[ $REPLY > 0 ]]; then DELAY=$REPLY; fi; echo -n "${red}DELAY=$DELAY${reset}"
echo
read -p  "Enter MIN_SPEED (default 20): "
if [[ $REPLY > 0 ]]; then MIN_SPEED=$REPLY; fi; echo -n "${red}MIN_SPEED=$MIN_SPEED${reset}"
echo
read -p  "Enter MIN TEMP (default 60): "
if [[ $REPLY > 0 ]]; then MIN_TEMP=$REPLY; fi; echo -n "${red}MIN_TEMP=$MIN_TEMP${reset}"
echo
read -p  "Enter MAX TEMP (default 70): "
if [[ $REPLY > 0 ]]; then MAX_TEMP=$REPLY; fi; echo -n "${red}MAX_TEMP=$MAX_TEMP${reset}"
echo
read -p  "Enter MIN_COEF (default 80): "
if [[ $REPLY > 0 ]]; then MIN_COEF=$REPLY; fi; echo -n "${red}MIN_COEF=$MIN_COEF${reset}"
echo
read -p  "Enter MAX_COEF (default 110): "
if [[ $REPLY > 0 ]]; then MAX_COEF=$REPLY; fi; echo -n "${red}MAX_COEF=$MAX_COEF${reset}"
echo
echo "Creating config..."
if [ ! -f "/home/user/autofan.conf" ]; then
		touch /home/user/autofan.conf
fi
echo -n > /home/user/autofan.conf
echo -e "DELAY=$DELAY\nMIN_SPEED=$MIN_SPEED\nMIN_TEMP=$MIN_TEMP\nMAX_TEMP=$MAX_TEMP\nMIN_COEF=$MIN_COEF\nMAX_COEF=$MAX_COEF" >> /home/user/autofan.conf
echo "${green}[Status]: ${reset}Config created."		
}

function check_run {
if [ ! -f "/home/user/xinit.user.sh" ]; then
		touch /home/user/xinit.user.sh
		chmod +x /home/user/xinit.user.sh
		echo -e "#!/bin/bash\nscreen -dmS autofan /home/user/$s_name -g" >> /home/user/xinit.user.sh
		echo -n "${green}[Status]: ${reset}File xinit.user.sh created."
else 
		if grep -q "screen -dmS autofan /home/user/$s_name -g" /home/user/xinit.user.sh; then
					echo -n "${green}[Status]: ${reset}Autorun switched on."
		else 
					echo -e "screen -dmS autofan /home/user/$s_name -g" >> /home/user/xinit.user.sh
					echo -n "${green}[Status]: ${reset}Autorun created."
					
		fi
echo
fi
}

function auto_fan {
CARDS_NUM=`nvidia-smi -L | wc -l`
echo "Found ${CARDS_NUM} GPU(s)"
echo -e -n "${green}Your current AUTOFAN settings:${reset}\nDELAY=$DELAY\nMIN_SPEED=$MIN_SPEED\nMIN_TEMP=$MIN_TEMP\nMAX_TEMP=$MAX_TEMP\nMIN_COEF=$MIN_COEF\nMAX_COEF=$MAX_COEF\n"
sleep 2
while true
        do
            echo -n "${green}$(date +"%d/%m/%y %T")${reset}"
			echo
        for ((i=0; i<$CARDS_NUM; i++))
            do
                
                GPU_TEMP=`nvidia-smi -i $i --query-gpu=temperature.gpu --format=csv,noheader`
                if [ $GPU_TEMP -le $MIN_TEMP ]
                    then
                        FAN_SPEED=$(($GPU_TEMP * ($MIN_COEF-($MIN_TEMP - $GPU_TEMP) * 2)/100))
						if [ $FAN_SPEED -le $MIN_SPEED ] 
						then
								FAN_SPEED=$MIN_SPEED 
						fi

                elif [[ $GPU_TEMP > $MIN_TEMP ]] && [[ $GPU_TEMP < $MAX_TEMP ]]
                    then
						FAN_SPEED=$((  $GPU_TEMP *(($GPU_TEMP - $MIN_TEMP) * 4 + $MIN_COEF)/100 ))

				elif [ $GPU_TEMP -ge $MAX_TEMP ]
                    then
						FAN_SPEED=$(( $GPU_TEMP *(($GPU_TEMP - $MAX_TEMP) * 4 + $MAX_COEF)/100 ))
                fi

		if [ $FAN_SPEED -gt 100 ]
				then
					FAN_SPEED=100
		fi
                nvidia-settings -a [gpu:$i]/GPUFanControlState=1 > /dev/null
				nvidia-settings -a [fan:$i]/GPUTargetFanSpeed=$FAN_SPEED > /dev/null
                echo "GPU${i} ${GPU_TEMP}°C -> ${FAN_SPEED}%"
       done
sleep $DELAY
done
}

function ghost_run {
read -p  "Run script in GHOST mode? (y/n) "
if [[ $REPLY = "y" ]] ;then 
			
			screen -dmS autofan /home/user/$s_name -g
			echo "Your choice is ${green}[YES]${reset}."
			echo -n "${green}Script started in GHOST mode.${reset}"
			echo
elif [[ $REPLY = "n" ]] ; then
							echo "Your choice is ${red}[NO]${reset}."
							read -p  "Run script in default mode? (y/n) "
							if [[ $REPLY = "y" ]] ; then $s_name -g
							else echo "Your choice is ${red}[NO]${reset}. See your later.."; exit
							fi
else 
echo "${red}[FAIL] ${reset} Please, make a choice."
ghost_run
fi
}

if test -f "/home/user/autofan.conf" ; then source /home/user/autofan.conf ; fi

if [[ $1 = "-g" ]]; then 
		auto_fan
elif [[ $1 = "-s" ]]; then
		set_var
		ghost_run
elif [[ $1 = "-c" ]]; then
		if screen -ls | grep -q "autofan"; then
		echo "${green}The script is running.${reset}"
		else echo "${red}The script is NOT running.${reset}"
		fi
		echo -e -n "${green}Your current AUTOFAN settings:${reset}\nDELAY=$DELAY\nMIN_SPEED=$MIN_SPEED\nMIN_TEMP=$MIN_TEMP\nMAX_TEMP=$MAX_TEMP\nMIN_COEF=$MIN_COEF\nMAX_COEF=$MAX_COEF\n"
elif [[ $1 = "-k" ]]; then
			pkill $s_name
else 
		echo -n "${green}HiveOS autofan script for NVIDIA GPU.${reset} v.${VERSION}"
		echo
		set_var
		check_run
		ghost_run
fi

exit
