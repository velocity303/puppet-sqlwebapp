class sqlwebapp (
  $sqldatadir    = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MYINSTANCE\MSSQL\DATA',
  $docroot       = 'C:/inetpub/wwwroot',
  $dbserver      = $::fqdn,
  $db_instance   = 'MYINSTANCE',
  $iis_site      = 'Default Web Site',
  $file_source   = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
  $db_password   = 'Azure$123',
  $webapp_zip    = 'CloudShop.zip',
  $webapp_name   = 'CloudShop',
  $webapp_config = 'Web.config',
) {
  require sqlwebapp::iis
  file { "${docroot}/${webapp_name}":
    ensure  => directory,
  }
  staging::file { $webapp_zip:
    source => "${file_source}/${webapp_zip}",
  }
  unzip { "Unzip webapp ${webapp_zip}":
    source      => "C:/staging/${module_name}/${webapp_zip}",
    creates     => "${docroot}/${webapp_name}/${webapp_config}",
    destination => "${docroot}/${webapp_name}",
    require     => Staging::File[$webapp_zip],
    notify      => Exec['ConvertAPP'],
  }
  file { "${docroot}/${webapp_name}/${webapp_config}":
    ensure  => present,
    content => template("${module_name}/Web.config.erb"),
    require => Unzip["Unzip webapp ${webapp_zip}"],
  }
  exec { 'ConvertAPP':
    command     => "ConvertTo-WebApplication \'IIS:/Sites/${iis_site}/${webapp_name}\'",
    provider    => powershell,
    refreshonly => true,
  }
}
