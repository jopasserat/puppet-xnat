# Licensed to Biomedical Imaging Group Rotterdam under one or more contributor 
# license agreements. Biomedical Imaging Group Rotterdam licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

define xnat::fill_database (
  $system_user, 
  $installer_dir,
  $instance_name,
  $db_username)
{
  if $database_exists == 1 {
    notify {"postgresql database already configured": }

  } else {
    notify {"configuring postgresql database": } ->    

    # Do database configuration
    exec { "create_tables":
      command => "su xnat -c 'psql -d $system_user -f $installer_dir/deployments/$instance_name/sql/$instance_name.sql -U $db_username'"
    } ->

    # Set security settings
    exec { "store_security_settings":
      command => "$installer_dir/bin/StoreXML -project $instance_name -l security/security.xml -allowDataDeletion true > security.out",
      cwd => "$installer_dir/deployments/$instance_name"
    } ->

    # Set example datasets
    # Have to redirect output otherwise puppet sees it as an error
    exec { "store_example_sets":
      command => "$installer_dir/bin/StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true > sets.out",
      cwd => "$installer_dir/deployments/$instance_name"
    }
  }
}
