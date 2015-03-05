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
