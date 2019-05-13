# mcpcollect_idrac
Collect logs from Dell Idrac based on information stored in MCP reclass model.  This requires that SSH access be enabled on the IDRAC.

This script will pull power information from mass pillar, use this information to log into a Dell Idrac and pull the logs.

The current form of the script creates an "output script" that is an ssh command to run to collect the logs.

This was done done becuase some customer have the reclass in environments that dont have access to the IDRAC.  It is necessary to produce the output that can be pasted to the other environment.

