# Convert service testing

This project need to test onlyoffice documentserver via [convert service](https://api.onlyoffice.com/editors/conversionapi)

## Getting started locally

>In order to start it, a set of keys must first be installed on the host

  1. For local startup in developer mode,
    recommended installing a local `bundle config` file.

      ```bash
        bundle config set --local with development
      ```

  2. Afterwards install the dependencies with the bundle.

      ```bash
        bundle install
      ```

  3. Reconfigure `docker-compose.yml` via `nginx`

      Specify the path to the local directory in the config
      file for the volume setting

      ```yml
        nginx:
        ...
          volumes:
      - ./files_tmp:/usr/share/nginx/html/
        ...
      ```

  4. Run auxiliary containers (wait ~120 sec)

      ```bash
        docker-compose up -d documentserver
        docker-compose up -d nginx
      ```
  
  5. Configuration .env

      * `DOCSERVER_VERSION` must contain the version of the server document:

        example: **7.3.0.100**

  6. Configuration ENV`s

      file `spec/spec_helper.rb` contains global variables.
      Explain them and fill them out similarly to the chart:

      >Warning: The path must not contain a slash at the end

      ```ruby
      # ENV['DOCUMENTSERVER'] = '[URL to server]'
      # ENV['NGINX'] = '[URL to nginx]'
      # ENV['DOCUMENTSERVER_JWT'] = '[JWT key if enable]'
      ```
  
  7. Run all specs for convertation

      ```bash
        rspec
      ```

## Getting start via `docker-compose`

  1. Add all keys to `Dockerfile`:

      * `S3_KEY` - is a s3 public key
      * `S3_PRIVATE_KEY` - is a s3 private key
      * `PALLADIUM_TOKEN` - token for write result to **palladium**
      * `DOCUMENTSERVER_JWT` - **JWT** key is used by default (see the
      [documentation](https://helpcenter.onlyoffice.com/installation/docs-community-install-docker.aspx)
      on configuring the server document)

  2. Configuration `.env`

     * `DOCSERVER_VERSION` must contain the version of the server document:

        >example: **7.3.0.100**

  3. Build and run project (*detached mode*):

      ```bash
        docker-compose up -d
      ```

  4. In a few minutes the results will start to be recorded in `palladium`

## How it work

  File will be downloaded from s3 to `file_tmp`.
  This folder (volume) is a same for `testing_project` and `nginx`.
  
  After it, `testing_project` will send request to document server
  with link to file from `nginx`.

  After conversion, response will parsed, and result will send to [palladium](https://github.com/ONLYOFFICE-QA/palladium-view)

## Troubleshooting

* Error in response (-1, -2, -3,  -7)

  At first, you need to open file in editors and save in like *pdf*, and after it
  you need to create new bug to **Konovalov Sergey**.

  Example of bug report - **45253** (private bug tracker)

* Error in response -4

  It is because file can not to be downloaded by convert service.
  Check downloading inside of documentserver docker container.
  If it work, you need to add `access control allow origin`,
  or something like it to your web server with files. Read more about in
  [documentation](https://api.onlyoffice.com/editors/conversionapi#error-codes).

  If you still not convert file,  pay attention to existing localhosts in url's
