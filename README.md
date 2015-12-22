##sqlwebapp

This module is intended to be used in tangent with the tse_sqlserver module (https://github.com/velocity303/tse_sqlserver). This is a sample profile showing the deployment of a small IIS webapp that requires interraction with MS SQL Server for functinoality.

There are three main components of this module:

`sqlwebapp`
This class will deploy the CloudShop application onto a Windows server using the sqlwebapp::iis class to install IIS first. This does not install the db portion of the code that is required for full function. The application code will be downloaded from a staged location in AWS.

`sqlwebapp::db` This class will install the database portions of the application code utilizing the tse_sqlserver::attachdb defined type. This by default will download the application db from a staged location in AWS.

`sqlwebapp::iis` This class will install the IIS requirements for CloudShop. This is rarely necessary to include on its own.

###Integration with tse_sqlserver:

If you would like to have a simple installation you can create a new server role such as the following:

```puppet
class role::win_sqlweb_demo {
  include tse_sqlserver
  include sqlwebapp::db
  include sqlwebapp
}
```

This will include, along with all the defaults, a basic setup of the full application on a single node.

Additonally, if taking advantage of application orchestration, you can utilize the CloudShop module to add that capability to these modules (https://github.com/velocity303/puppet-cloudshop).
