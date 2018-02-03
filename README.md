# lnsLxc
lift and shift with lxc

Current challenges for lift and shift:
~ Huge manual intervention Involved in performing Lift and Shift
~ Application configuration like Autoconfig , etc. required to be executed at application & DB layer
~ Application Product expertise required to complete the process
~ Chances of errors and troubleshooting required

Benefits of using LXC:
~ Zero changes at Application/DB layer
~ Lift and Shift of Apps not dependent on Product expertise
~ Same template can be used for any Apps
~ Can be fully automated
~ Seamless replication strategy for DR

Steps to use above tool:
1. Place all the scripts in /tmp/lnsLxc of  source server
2. Place rsa key in openssh format in /tmp/lnsLxc and append the public key to /home/opc/.ssh/authorized_keys file in target server.
3. Fill the reqiored values in lns.cfg
4. Run lns.sh
5. All the configuration files and shell script to start the container will be available on the target server in the location mentioned in lns.cfg.
