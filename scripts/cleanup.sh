#!/usr/bin/bash

# Prepares a Ubuntu Server guest operating system. Can't remember the author/source of this script, but not from me !

### Create a cleanup script. ###
echo '> Creating cleanup script ...'
sudo cat <<EOF > /tmp/cleanup.sh
#!/bin/bash
# Cleans all audit logs.
echo '> Cleaning all audit logs ...'
if [ -f /var/log/audit/audit.log ]; then
cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
cat /dev/null > /var/log/lastlog
fi
# Cleans persistent udev rules.
echo '> Cleaning persistent udev rules ...'
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
rm /etc/udev/rules.d/70-persistent-net.rules
fi
# Cleans /tmp directories.
echo '> Cleaning /tmp directories ...'
rm -rf /tmp/*
rm -rf /var/tmp/*
# Cleans SSH keys.
echo '> Cleaning SSH keys ...'
rm -f /etc/ssh/ssh_host_*
# Cleans apt-get.
echo '> Cleaning apt-get ...'
apt autoremove -y
apt clean -y
# Cleans the machine-id.
echo '> Cleaning the machine-id ...'
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
# Cleans shell history.
echo '> Cleaning shell history ...'
unset HISTFILE
history -cw
echo > ~/.bash_history
rm -fr /root/.bash_history
# Cloud Init Nuclear Option
cloud-init clean
rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
rm -rf /etc/cloud/cloud.cfg.d/99-installer.cfg
echo "disable_vmware_customization: false" >> /etc/cloud/cloud.cfg
echo "# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ VMware, OVF, None ]" > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
# Set boot options to not override what we are sending in cloud-init
echo '> modifying grub'
sed -i -e "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub
update-grub
echo '> trim disks'
fstrim -av
EOF

### Change script permissions for execution. ### 
echo '> Changeing script permissions for execution ...'
sudo chmod +x /tmp/cleanup.sh


### Executes the cleanup script. ### 
echo '> Executing the cleanup script ...'
sudo /tmp/cleanup.sh

### All done. ### 
echo '> Done.' 
