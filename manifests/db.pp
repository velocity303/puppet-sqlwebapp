class sqlwebapp::db (
  $dbinstance    = 'MYINSTANCE',
  $dbpass        = 'Azure$123',
  $dbuser        = 'CloudShop',
  $file_source   = 'https://s3-us-west-2.amazonaws.com/tseteam/files/sqlwebapp',
){
  tse_sqlserver::attachdb { 'AdventureWorks2012':
    file_source => $file_source,
    dbinstance  => $dbinstance,
    dbpass      => $dbpass,
    dbuser      => $dbuser,
  }
}
