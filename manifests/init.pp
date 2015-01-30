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
  $sqldatadir  = 'C:/Program Files/Microsoft SQL Server/MSSQL12.MYINSTANCE/MSSQL/DATA/',
  $docroot     = 'C:/inetpub/wwwroot',
  $db_instance = 'MYINSTANCE',
  $iis_site    = 'Default Web Site',
) {
  include profile::windows::sql
  include profile::windows::iisdb
  file { "${docroot}/CloudShop":
    ensure  => directory,
    require => Class['profile::windows::iisdb'],
  }
  staging::deploy { "AdventureWorks2012_Data.zip":
    target  => $sqldatadir,
    creates => "${sqldatadir}/AdventureWorks2012_Data.mdf",
    source  => "http://master.inf.puppetlabs.demo/AdventureWorks2012_Data.zip",
    require => Class['profile::windows::sql'],
    notify  => Exec['SetupDB'],
  }
  staging::deploy { "CloudShop.zip":
    target  => "${docroot}/CloudShop",
    creates => "${docroot}/CloudShop/packages.config",
    source  => "http://master.inf.puppetlabs.demo/CloudShop.zip",
    require => File["${docroot}/CloudShop"],
    notify  => Exec['ConvertAPP'],
  }
  file { "${docroot}/CloudShop/Web.config":
    ensure  => present,
    content => template('profile/Web.config.erb'),
    require => Staging::Deploy['CloudShop.zip'],
  }
  file { 'C:/AttachDatabasesConfig.xml':
    ensure  => present,
    content => template('profile/AttachDatabasesConfig.xml.erb'),
  }
  exec { 'SetupDB':
    command     => template('profile/AttachDatabase.ps1'),
    provider    => powershell,
    refreshonly => true,
    logoutput   => true,
  }
  exec { 'ConvertAPP':
    command     => "ConvertTo-WebApplication \"IIS:\Sites\${iis_site}\CloudShop\"",
    provider    => powershell,
    refreshonly => true,
  }
  sqlserver::login{'CloudShop':
     instance => $db_instance,
     password => 'Azure$123',
  }  
}
