**XNAT puppet module**
==================
This module deploys and configures an XNAT installation using Puppet.

Installation
---------------

See the `INSTALL <INSTALL.md>`_ file for the prerequisites before using the puppet script. See Installation Configuration below for important settings.

The puppet script installs several services and packages. The install locations vary per package. We provide the following table with the exact details per package that can be used in case of errors, later updates or partial installs/repairs. For repairing or updating a system, the puppet script can be ru-run, even the puppet script is not changed. It uses the checks that are listed in the Check column to determine if a package is already installed. If one makes the check condition false (e.g. removing the listed directory), the puppet script will re-install that specific package. Beside the checks, the puppet script will -always- copy the latest XNAT build to the tomcat webapps directory and restart the service.

The puppet column lists if the package is installed as a puppet module or custom installation (e.g. download and install zip/tar.gz).


======   ==========   ==========================  ============================
Puppet   Package      Install location            Check
======   ==========   ==========================  ============================
No       java         /usr/lib/jvm/{version}      If install location exists
Yes      postgresql   via package manager         Determined by puppet package
No       tomcat       /usr/share/tomcat{version}  If install location exists
No       xnat         /home/xnat/xnat             If install location exists
Yes      nginx        via package manager         Determined by puppet package
======   ==========   ==========================  ============================

*Other checks*

============================   =========================================
Item                            Check
============================   =========================================
Install database               If database 'xnat' exists (see notes)
Build XNAT                     If {xnat}/deployments directory exists
Shutdown tomcat                If {tomcat}/bin/.shutdown.sh exists
Move tomcat ROOT (see notes)   If {tomcat}/webapps/tomcat does not exist
============================   =========================================

*Notes*

- An Nginx proxy is used to redirect requests from port 443 to 8080, which is tomcat's default port.
- The puppet script also copies a .jinfo file to the java installation location. This is required for a correct java installation with the update-alternatives application.
- The xnat database can be removed the following way (for testing):
 NOTE: ALL XNAT DATA WILL BE REMOVED! MAKE A BACKUP!
 - sudo -u postgres psql
 - DROP DATABASE xnat
 - \q (for exit psql)
- The XNAT installation can be run with SELinux Enabled. The script has been adapted and tested to run with SELinux.
- The script downloads the given version from the XNAT ftp side.
- The script does not modify any firewall settings, for security reasons. To make the website accessable, please make sure that port 80 and 8104 (dicom gateway) are open in iptables or any other firewall service.


Installation configuration
-----------------------------

Several settings can be configured in the file `/etc/puppet/modules/xnat/tests/test.pp`
Please review these settings before running the puppet script.

Noteworthy settings:

- db_userpassword should be set to a new password for the database.
- archive_root is where all imaging data (and support files) are stored.
- tomcat_web_user/password can be set to access tomcat's status/management pages.
- catalina_tmp_dir should be linked to a location with sufficient space. Uploads are also temporarily stored here, which can take up several GB's, depending on the upload datasize.
- tablespace_dir is the location of the database. This can be changed for improved backup support or to move the database to a faster disk, if required.
- java_opts should be changed accordinly, based on the systems memory availibility.
- if any of the directories are changed, please also update the makedirs.sh (next to test.pp) accordingly.

Compatibility
-------------

The script has been tested on:

- Fedora 20.1
- RedHat Server 7.0
- Scientific Linux 6.5
- Ubuntu Server 14.0.4.1

Licencing
---------

This work is distributed under the `GNU Affero GPL v3.0 <http://www.gnu.org/licenses/agpl-3.0.txt>`_.

This work reuses the Puppet module provided by the Bigr group from Erasmus university.
The base puppet module is available `here <https://bitbucket.org/bigr_erasmusmc/puppet-xnat>`_ under an Apache 2.0 Licence.

The AGPL v3.0 only concerns the modified parts and is not an attempt to modify the distribution licence from Bigr's Puppet module.

Acknowledgements
----------------

Thanks to Stefan Klein (Erasmus MC), Marcel Koek (Erasmus MC), Erwin Vast (Erasmus MC) and Pieter Lukasse (The Hyve) for the original works towards an automation of XNAT's installation process using Puppet.
