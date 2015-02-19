# == Class: sqlwebapp
#
# Full description of class sqlwebapp here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { sqlwebapp:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
#
class sqlwebapp (
  $sqldatadir    = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MYINSTANCE\MSSQL\DATA',
  $docroot       = 'C:/inetpub/wwwroot',
  $db_instance   = 'MYINSTANCE',
  $iis_site      = 'Default Web Site',
  $file_source   = 'http://master.inf.puppetlabs.demo',
  $db_password   = 'Azure$123',
  $webapp_zip    = 'CloudShop.zip',
  $webapp_name   = 'CloudShop',
  $webapp_config = 'Web.config',
) {
  file { "${docroot}/${webapp_name}":
    ensure  => directory,
    require => Class['tse_sqlserver::iisdb'],
  }
  staging::deploy { $webapp_zip:
    target  => "${docroot}/${webapp_name}",
    creates => "${docroot}/${webapp_name}/${webapp_config}",
    source  => "${file_source}/${webapp_zip}",
    require => File["${docroot}/${webapp_name}"],
    notify  => Exec['ConvertAPP'],
  }
  file { "${docroot}/${webapp_name}/${webapp_config}":
    ensure  => present,
    content => template("${module_name}/Web.config.erb"),
    require => Staging::Deploy[$webapp_zip],
  }
  exec { 'ConvertAPP':
    command     => "ConvertTo-WebApplication \'IIS:/Sites/${iis_site}/${webapp_name}\'",
    provider    => powershell,
    refreshonly => true,
  }
}
