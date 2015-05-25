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

class xnat::get_xnat (
  $xnat_version,
  $xnat_local_install
)
{
  if $xnat_local_install == '' {
    archive { "xnat-$xnat_version":
      ensure => present,
      url => "ftp://ftp.nrg.wustl.edu/pub/xnat/xnat-$xnat_version.tar.gz",
      target => "/home/xnat",
      extension => 'tar.gz',
      checksum => true,
      src_target => '/tmp',
      timeout => 7200,
    }
  } else {
    rsync::get { "/tmp/xnat-$xnat_version.tar.gz":
      source => $xnat_local_install,
    } ->

    archive::extract { "xnat-$xnat_version":
      ensure => present,
      target => "/home/xnat",
      src_target => "/tmp/",
      extension => 'tar.gz',
      require => Rsync::Get["/tmp/xnat-$xnat_version.tar.gz"]
    }
  }
  ->
  # workaround for https://github.com/camptocamp/puppet-archive/issues/46
  exec {'move xnat to expected location':
    command => "mv /home/xnat/xnat-$xnat_version /home/xnat/xnat",
  }
}
