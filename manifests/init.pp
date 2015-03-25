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
  contain sqlwebapp::iis
  file { "${docroot}/${webapp_name}":
    ensure  => directory,
    require => Class['sqlwebapp::iis'],
  }
  file { "C:/${webapp_zip}":
    ensure  => present,
    source  => "${file_source}/${webapp_zip}",
    require => File["${docroot}/${webapp_name}"],
  }
  unzip { "Unzip webapp ${webapp_zip}":
    source      => "C:/${webapp_zip}",
    creates     => "${docroot}/${webapp_name}/${webapp_config}",
    destination => "${docroot}/${webapp_name}",
    require     => File["C:/${webapp_zip}"],
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
