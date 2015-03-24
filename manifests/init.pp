class sqlwebapp (
  $sqldatadir    = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MYINSTANCE\MSSQL\DATA',
  $docroot       = 'C:/inetpub/wwwroot',
  $db_instance   = 'MYINSTANCE',
  $iis_site      = 'Default Web Site',
  $file_source   = 'puppet:///modules/sqlwebapp/',
  $db_password   = 'Azure$123',
  $webapp_zip    = 'CloudShop.zip',
  $webapp_name   = 'CloudShop',
  $webapp_config = 'Web.config',
) {
  require sqlwebapp::iis
  file { "${docroot}/${webapp_name}":
    ensure  => directory,
  }
  file { "${docroot}/${webapp_zip}":
    ensure => present,
    source => "${file_source}/${webapp_zip}",
  }
  unzip { "Unzip webapp ${webapp_zip}":
    source      => "${path}/${zip_file}",
    creates     => "${docroot}/${webapp_name}/${webapp_config}",
    destination => "${docroot}/${webapp_name}",
    require     => File["${docroot}/${webapp_zip}"],
    notify      => Exec['ConvertApp'],
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
