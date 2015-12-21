class sqlwebapp (
  $dbserver      = $::fqdn,
  $dbinstance    = 'MYINSTANCE',
  $dbpass        = 'Azure$123',
  $dbuser        = 'CloudShop',
  $dbname	 = 'AdventureWorks2012',
  $iis_site      = 'Default Web Site',
  $docroot       = 'C:/inetpub/wwwroot',
  $file_source   = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
) {
  require sqlwebapp::iis
  file { "${docroot}/CloudShop":
    ensure  => directory,
  }
  staging::file { 'CloudShop.zip':
    source => "${file_source}/CloudShop.zip",
  }
  unzip { "Unzip webapp CloudShop":
    source      => "C:/staging/${module_name}/CloudShop.zip",
    creates     => "${docroot}/CloudShop/Web.config",
    destination => "${docroot}/CloudShop",
    require     => Staging::File['CloudShop.zip'],
    notify      => Exec['ConvertAPP'],
  }
  file { "${docroot}/CloudShop/Web.config":
    ensure  => present,
    content => template("${module_name}/Web.config.erb"),
    require => Unzip["Unzip webapp CloudShop"],
  }
  exec { 'ConvertAPP':
    command     => "ConvertTo-WebApplication \'IIS:/Sites/${iis_site}/CloudShop\'",
    provider    => powershell,
    refreshonly => true,
  }
}
