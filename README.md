# lnsLxc
lift and shift with lxc

Current challenges for lift and shift:
1. Huge manual intervention Involved in performing Lift and Shift
2. Application configuration like Autoconfig , etc. required to be executed at application & DB layer
3. Application Product expertise required to complete the process
4. Chances of errors and troubleshooting required

Benefits of using LXC:
1. Zero changes at Application/DB layer
2. Lift and Shift of Apps not dependent on Product expertise
3. Same template can be used for any Apps
4. Can be fully automated
5. Seamless replication strategy for DR

Steps to use above tool:
1. Place all the scripts in /tmp/lnsLxc of  source server
2. Place rsa key in openssh format in /tmp/lnsLxc and append the public key to /home/opc/.ssh/authorized_keys file in target server.
3. Fill the reqiored values in lns.cfg
4. Run lns.sh
5. All the configuration files and shell script to start the container will be available on the target server in the location mentioned in lns.cfg.
