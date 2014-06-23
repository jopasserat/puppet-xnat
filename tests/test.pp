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

xnat::xnatapp { 'xnat-web-app-1':
  db_name => "xnat",
  db_username => "xnat",
  db_userpassword => "blaat123",
  system_user => "xnat",
  instance_name => "xnat",
  archive_root => "/xnatdata",
  tomcat_web_user => "evast",
  tomcat_web_password => "test123"
}
