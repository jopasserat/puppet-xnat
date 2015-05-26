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

define download_xnat (
  $xnat_version,
  $installer_dir,
  $xnat_local_install
)
{
  if $xnat_exists == 'true' {
    notify {"xnat already installed": }
  } else {
    notify { "downloading XNAT ...": } ->

    class {"xnat::get_xnat": 
      xnat_version => $xnat_version,
      xnat_local_install => $xnat_local_install
    } ->

    # Clone the xnat builder dev branch, create files and set permissions (step 1)
    #exec { "mercurial-clone-xnatbuilder":
    #  command => "hg clone http://hg.xnat.org/xnat_builder_1_6dev $installer_dir$
    #  creates => $installer_dir,
    #  timeout => 7200,
    #} ->

    #notify { "downloading XNAT pipeline ...": } ->

    #exec { "mercurial-clone-xnat-pipeline":
    #  command => "hg clone http://hg.xnat.org/pipeline_1_6dev $installer_dir/pip$
    #  creates => "$installer_dir/pipeline",
    #  timeout => 7200,
    #} ->

    # workaround for https://github.com/camptocamp/puppet-archive/issues/46
    exec {'move xnat to expected location':
      command => "mv /home/xnat/xnat-$xnat_version /home/xnat/xnat",
    } ->
    # Cleanup
    exec { "remove /tmp/xnat*":
      command => "rm -f /tmp/xnat*"
    } ->

    notify { "downloading XNAT and pipeline complete": }
  }
}
