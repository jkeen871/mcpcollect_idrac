#!/bin/bash

for x in `cat nodenames`; do
#       echo "sudo salt-call pillar.data maas:region:machines:$x:power_parameters:power_address 2> /dev/null"
#        echo ""
#        echo "Hostname : $x"
#        echo ""
        salttest=`sudo salt-call pillar.data maas:region:machines:$x 2>/dev/null| tail -1`
        if [[ $salttest =~ .*$x.* ]]; then
                echo "Failed to get salt results for $x"
        else
                dracip=`sudo salt-call pillar.data maas:region:machines:$x:power_parameters:power_address 2> /dev/null | tail -1 | sed 's/ //g'`
                dracpw=`sudo salt-call pillar.data maas:region:machines:$x:power_parameters:power_password 2> /dev/null | tail -1| sed 's/ //g'`
                dracid=`sudo salt-call pillar.data maas:region:machines:$x:power_parameters:power_user 2> /dev/null| tail -1|sed 's/ //g'`
#                echo "IP : $dracip"
#                echo "PW : $dracpw"
#                echo "ID : $dracid"
                echo "mkdir /tmp/mcpcollect_idrac;sshpass -p '$dracpw' ssh -o StrictHostKeyChecking=no $dracid@$dracip 'racadm getsel' > /tmp/mcpcollect_idrac/idrac_$x.log"
        fi
done

