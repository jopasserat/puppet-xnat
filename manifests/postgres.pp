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

define xnatapp::postgres (
  $system_user, 
  $installer_dir,
  $instance_name,
  $db_username)
{
  unless $database_exists == 1 {

    # Install plpgsql (required on some systems with Postgres < 9
    # Have to do it manually, no existing function available
    exec { "install_plpgsql":
      command => "su postgres -c 'createlang -d xnat plpgsql'"
    } ->


    # Do database configuration (step 5)
    exec { "create_tables":
      command => "su xnat -c 'psql -d $system_user -f $installer_dir/deployments/$instance_name/sql/$instance_name.sql -U $db_username > /home/xnat/psql.out'",
    } ->

    # Security settings (step 7)
    exec { "store_security_settings":
      command => "$installer_dir/bin/StoreXML -project $instance_name -l security/security.xml -allowDataDeletion true > security.out",
      cwd => "$installer_dir/deployments/$instance_name",
    } ->

  # Example sets (step 8)
    exec { "store_example_sets":
      command => "$installer_dir/bin/StoreXML -dir ./work/field_groups -u admin -p admin -allowDataDeletion true > example.out",
      cwd => "$installer_dir/deployments/$instance_name",
    }
  }
}
