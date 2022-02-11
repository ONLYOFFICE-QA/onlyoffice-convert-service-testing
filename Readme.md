# Convert service testing

This project need to test onlyoffice documentserver via convert service

## Getting start

Add all keys to dockerfile

* S3_KEY - is a s3 public key
* S3_PRIVATE_KEY - is a s3 private key
* PALLADIUM_TOKEN - token for write result to palladium
* DOCUMENTSERVER_JWT - JWT key is used by default (see the
[documentation](https://helpcenter.onlyoffice.com/installation/docs-community-install-docker.aspx)
on configuring the server document)

Do not forget to change documentserver version from docker-compose file
(default - **4testing-documentserver-ie:latest**)

Run tests:

`docker-compose up -d`

## How it work

File will be downloaded from s3 to `file_tmp`.
This folder is a same for `testing_project` and `nginx`.
After it, `testing_project` will send request to documentserver
with link to file from nginx.
After conversion, response will parsed, and result will send to palladium

## Troubleshooting

* Error in response (-1, -2, -3,  -7)

  At first, you need to open file in editors and save in like pdf, and after it
  you need to create new bug to Konovalov Sergey. Example of bug report - 45253

* Error in response -4

  It is because file can not to be downloaded by convert service.
  Check downloading inside of documentserver docker container.
  If it work, you need to add `access control allow origin`,
  or something like it to your web server with files. Read more about in
  [documentation](https://github.com/ONLYOFFICE/testing-documentserver/wiki/Plugins:-Adding-new-plugin).
  If you still not convert file,  pay attention to existing localhosts in url's
