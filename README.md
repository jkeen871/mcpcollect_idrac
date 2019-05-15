# mcpcollect_idrac


This tool is intended to be run from the CFG host in your MCP environment
Pulls logs, service tag, sensor information, and hardware information from dell iDrac based on the MCP Reclass hostname.
       ** Requires ssh access to be enabled on the iDrac from the CFG host

mcpcollect_idrac.sh -h [target host] -h [target host2] -o [output script]

    -h -- the hostname in reclass that you wish to collect iDrac information for, support for multiple hosts supported.
    -o -- specify and output script, with this option the a script will be created that can be executed from a host with ssh access to the iDRAC.  This must be gereated on the CFG host in order to get authentication information from the reclass model


