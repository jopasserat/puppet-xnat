Installation instructions
=========================

*Some steps may not be required on existing systems.*  
*For Scientific Linux the Fedora steps can be followed.* 

 - Log in as root
 - Install puppet
   - Fedora: `yum install puppet`
   - Ubuntu: `apt-get install puppet`
   - RedHat: 
     - for below: replace the 7s with 6s or 5s if that is the installed RedHat version. Replace x86_64 with i386 for systems with a 32-bit instruction set.
     - `sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm`
     - Install puppet: `yum install puppet` (confirm any required keys)
 - Install git: `yum install git` (confirm any required keys)
 - Update the operating system (if preferred): `yum update`
 - Retrieve the puppet repository: `git clone https://github.com/jopasserat/puppet-xnat /etc/puppet/modules/xnat` (space after puppet-xnat)
 - Run install script (also runs Puppet script). `sh /etc/puppet/modules/xnat/preinstall.sh`

Notes:
------

 - The output of the puppet script can be found in /puppet.out for debugging any problems (should not occur)
 - The complete installation can take up to an hour depending on internet/computer speed. 
 - For security reasons, this XNAT installation only uses an https/SSL connection. Default self-signed key/certificate are created, so feel to replace them with your own.
 - When XNAT is installed for the first time, an configuration window is opened when browsing to the machine web ip/address (login is admin/admin). Configure all settings. Note: you should provide the directories in which the image data should be stored. This is already configured by the puppet script, but make sure these directories have sufficient disk space available.

Known issues with installation (but rare):
------------------------------------------

 - Sometimes tomcat does not shutdown properly and therefore multiple instances are running. If the website is not reachable, check with `ps aux | grep java` if multiple tomcat instances are running. If this is the cast, kill the processes with `kill -9 [PID from ps aux]` and restart tomcat with `sh /usr/share/tomcat7/bin/startup.sh` . After about a minute the website should be reachable.
 - The installation script automatically detects the ip address of the installation machine. In some situations this does not work properly. If you cannot access the website, you can manually configure the ip-address in */usr/share/tomcat7/webapps/ROOT/WEB-INF/conf/InstanceSettings.xml* on line 3. Furthermore, if it still does not work, you can set the org.restlet.autoWire param-value on false in */usr/share/tomcat7/webapps/ROOT/WEB-INF/web.xml* on line 40.

