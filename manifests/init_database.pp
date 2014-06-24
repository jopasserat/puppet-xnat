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

define xnat::init_database (
  $db_username,
  $db_userpassword,
  $db_name,
  $tablespace_dir)
{
  class {"xnat_tablespace":
    tablespace_dir => $tablespace_dir
  } ->

  # Add user with password
  postgresql::server::role { $db_username:
    createrole => true,
    password_hash => $db_userpassword
  } ->

  # Add tablespace
  postgresql::server::tablespace { "tablespace_xnat":
    location => $tablespace_dir,
  } ->

  # Configure the postgres db
  postgresql::server::db { $db_name:
    user => $db_username,
    password => $db_userpassword,
    tablespace => "tablespace_xnat",
  } ->

  # Install plpgsql language
  plpgsql{ "install_plpgsql":
  }
}
