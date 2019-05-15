#    this program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    <http://www.gnu.org/licenses/>.
#



datestamp=`date '+%Y%m%d%H%M%S'`
localbasedir="/tmp/mcpcollectIdrac-$USER/$datestamp"

function usage {
        echo ""
        echo "This tool is intended to be run from the CFG host in your MCP environment"
        echo "Pulls logs, service tag, sensor information, and hardware information from dell iDrac based on the MCP Reclass hostname."
        echo "       ** Requires ssh access to be enabled on the iDrac from the CFG host"
        echo ""
        echo "   -h -- the hostname in reclass that you wish to collect iDrac information for"
        echo ""
        echo "   -o -- specify and output script, with this option the a script will be created that can be executed from a host with"
        echo "         ssh access to the iDRAC.  This must be gereated on the CFG host in order to get authentication information from "
        echo "         the reclass model"
        exit
}


declare -g IpmiCmds=(   \
                        "racadm getsvctag" \
                        "racadm getsel" \
                        "racadm getraclog -c100" \
                        "racadm getsensorinfo" \
                        "racadm hwinventory" \
                   )

while getopts "h:o:" arg; do
        case $arg in
                h) targetHosts+=("$OPTARG");;
                o) outputFlag=true;outputfile="$localbasedir/$OPTARG";;
                *) usage;;
                \?) usage;;
        esac
done
if [ $OPTIND -eq 1 ]; then usage ; fi
for targetIdrac in ${targetHosts[@]};
do
	echo "$targetIdrac"
        sshOptions="-o StrictHostKeyChecking=no"
        salttest=`sudo salt-call pillar.data maas:region:machines:$targetIdrac 2>/dev/null| tail -1`
        echo $salttest
        if [[ $salttest =~ .*$targetIdrac.* ]] || [ ! $outputFlag ]; then
                echo "Failed to get salt results for $targetIdrac"
        else
                echo "Collecting IPMI from salt..."
                dracip=`sudo salt-call pillar.data maas:region:machines:$targetIdrac:power_parameters:power_address 2> /dev/null | tail -1 | sed 's/ //g'`
                dracpw=`sudo salt-call pillar.data maas:region:machines:$targetIdrac:power_parameters:power_password 2> /dev/null | tail -1| sed 's/ //g'`
                dracid=`sudo salt-call pillar.data maas:region:machines:$targetIdrac:power_parameters:power_user 2> /dev/null| tail -1|sed 's/ //g'`
                if [ ! $outputFlag ]; then
                echo "Verifying iDRAC version..."
                dracver=$(sshpass -p $dracpw ssh -o StrictHostKeyChecking=no $dracid@$dracip 'racadm getversion' | grep 'iDRAC Version'| awk '{print $1}')
                fi
                if [[ "$dracver" == *"iDRAC"* ]] || [ $outputFlag ] ; then
                        mkdir -p $localbasedir 2> /dev/null
                        if [ $outputFlag ]; then
                                echo "mkdir -p $localbasedir" >>$outputfile
                        fi
                        for ipmicmd in "${IpmiCmds[@]}";
                        do
                                getIpmi='echo -e "\n@@@========='$ipmicmd'=====\n">> '$localbasedir'/idrac_'$targetIdrac'.log;sshpass -p '$dracpw' ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no '$dracid@$dracip' "'$ipmicmd'" >> '$localbasedir'/idrac_'$targetIdrac'.log'
                                if [ ! $outputFlag ]; then
                                        echo "Collecting : $ipmicmd"
                                        eval $getIpmi
                                else
                                        echo 'echo "Collecting '$targetIdrac' : '$ipmicmd'"' >> $outputfile
                                        echo $getIpmi >> $outputfile
                                fi
                        done
                        if [ $outputFlag ]; then
                                chmod +x $outputfile
                                echo "Ouput script written to : "$outputfile
                                echo ""
                                echo "Copy this script to a node that has ssh open to the iDrac you want to collect from. Then execute it from there"
                                echo ""
                        else
                                echo "Output written to : $localbasedir/idrac_$targetIdrac.log"
                        fi

                 else
                         echo "Could not verify Dell iDrac"
                        exit
                 fi
        fi
done

