class sqlwebapp::db (
  $dbinstance    = 'MYINSTANCE',
  $dbpass        = 'Azure$123',
  $dbuser        = 'CloudShop',
){
  tse_sqlserver::attachdb { 'AdventureWorks2012':
    file_source => 'https://s3-us-west-2.amazonaws.com/tseteam/files/tse_sqlserver'
    dbinstance  => $dbinstance,
    dbpass      => $dbpass,
    dbuser      => $dbuser,
  }
}
