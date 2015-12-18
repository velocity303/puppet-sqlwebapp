class sqlwebapp::db {
  tse_sqlserver::attachdb { 'AdventureWorks2012':
    file_source => 'https://s3-us-west-2.amazonaws.com/tseteam/files/tse_sqlserver'
  }
}
