#!/bin/bash

function usage {
        echo ""
	echo "This tool is intended to be run from the CFG host in your MCP environment"
        echo "Pulls logs, service tag, sensor information, and hardware information from dell iDrac based on the MCP Reclass hostname."
        echo "       ** Requires ssh access to be enabled on the iDrac from the CFG host"
        echo ""
        echo "   -h -- the hostname in reclass that you wish to collect iDrac information for"
        echo ""
        exit
}


while getopts "h:" arg; do
        case $arg in
                h) targetIdrac=("$OPTARG");;
                *) usage;;
                \?) usage;;
        esac
done

if [ $OPTIND -eq 1 ]; then usage ; fi


        sshOptions="-o StrictHostKeyChecking=no "
        salttest=`sudo salt-call pillar.data maas:region:machines:$targetIdrac 2>/dev/null| tail -1`
        if [[ $salttest =~ .*$targetIdrac.* ]]; then
                echo "Failed to get salt results for $targetIdrac"
        else
                echo "Collecting IPMI from salt..."
                dracip=`sudo salt-call pillar.data maas:region:machines:$targetIdrac:power_parameters:power_address 2> /dev/null | tail -1 | sed 's/ //g'`
                dracpw=`sudo salt-call pillar.data maas:region:machines:$targetIdrac:power_parameters:power_password 2> /dev/null | tail -1| sed 's/ //g'`
                dracid=`sudo salt-call pillar.data maas:region:machines:$targetIdrac:power_parameters:power_user 2> /dev/null| tail -1|sed 's/ //g'`
                echo "Verifying iDRAC version..."
                dracver=$(sshpass -p $dracpw ssh $sshOptions $dracid@$dracip 'racadm getversion' | grep 'iDRAC Version'| awk '{print $1}')
                if [[ "$dracver" == *"iDRAC"* ]]; then
                        mkdir /tmp/mcpcollect_idrac 2> /dev/null
                        sshpass -p $dracpw ssh $sshOptions $dracid@$dracip 'racadm getsvctag' > /tmp/mcpcollect_idrac/idrac_svctag_$targetIdrac.log
                        sshpass -p $dracpw ssh $sshOptions $dracid@$dracip 'racadm getsel' > /tmp/mcpcollect_idrac/idrac_$targetIdrac.log
                        sshpass -p $dracpw ssh $sshOptions $dracid@$dracip 'racadm getraclog -c100' > /tmp/mcpcollect_idrac/idrac_rac_$targetIdrac.log
                        sshpass -p $dracpw ssh $sshOptions $dracid@$dracip 'racadm getsensorinfo' > /tmp/mcpcollect_idrac/idrac_sensor_$targetIdrac.log
                        sshpass -p $dracpw ssh $sshOptions $dracid@$dracip 'racadm hwinventory' > /tmp/mcpcollect_idrac/idrac_hwinventory_$targetIdrac.log
                else
                        echo "Could not verify Dell iDrac"
                fi
        fi


