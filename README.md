# mcpcollect_idrac
Collect logs from Dell Idrac based on information stored in MCP reclass model

This script will pull power information from mass pillar, use this information to log into a Dell Idrac and pull the logs.

The current form of the script creates an "output script" that is an ssh command to run to collect the logs.

This was done done becuase some environments have the recall and the access to the drac in different environments.  It is necessary to produce the output that can be pasted to the other environment.

