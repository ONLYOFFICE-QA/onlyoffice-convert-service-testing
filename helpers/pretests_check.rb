# frozen_string_literal: true

require 'net/http'
# class with methods for check working system before run tests
class PretestsCheck
  def self.pretests_check
    tmp_dir_check = FileHelper.dir_check_or_create 'files_tmp'
    documentserver_check = documentserver_available?
    nginx_check = nginx_available?
    s3_check = s3_available?
    palladium_token = palladium_token?

    unless tmp_dir_check && s3_check && documentserver_check && nginx_check && palladium_token
      highlight_relatively_result "tmp directory check: #{tmp_dir_check}"
      highlight_relatively_result "Documentserver check: #{documentserver_check}"
      highlight_relatively_result "Nginx check: #{nginx_check}"
      highlight_relatively_result "S3 check: #{s3_check}"
      highlight_relatively_result "Palladium token: #{palladium_token}"
      raise 'Pre-test checks is failed!'
    end
    FileHelper.clear_dir('files_tmp')
  end

  def self.highlight_relatively_result(entry)
    if entry['true']
      OnlyofficeLoggerHelper.log entry, 32 # green color
    else
      OnlyofficeLoggerHelper.log entry, 31 # red color
    end
  end

  def self.documentserver_available?
    OnlyofficeLoggerHelper.log("Check documentserver is available #{StaticData.documentserver_url}")
    status = request_to(StaticData.documentserver_url)

    OnlyofficeLoggerHelper.log("Documentserver on #{StaticData.documentserver_url} is unavailable") unless status
    status
  end

  def self.nginx_available?
    random_file_name = "#{Time.now.nsec}.txt"
    FileHelper.create_file("#{StaticData::TMP_FOLDER}/#{random_file_name}")
    status = request_to("#{StaticData.nginx_url}/#{random_file_name}")
    unless status
      OnlyofficeLoggerHelper.log("Nginx server on #{StaticData.nginx_url} can not send files fom #{StaticData::TMP_FOLDER} folder")
    end
    status
  end

  def self.s3_available?
    s3 = OnlyofficeS3Wrapper::AmazonS3Wrapper.new(bucket_name: 'conversion-testing-files', region: 'us-east-1')
    path = s3.download_file_by_name('docx/Doc8.docx', './files_tmp')
    File.file?(path) && File.size(path) > 1000
  end

  def self.request_to(path)
    url = URI.parse(path)
    req = Net::HTTP.new(url.host, url.port)
    req.use_ssl = (url.scheme == 'https')
    path = if url.path.empty?
             '/'
           else
             url.path
           end
    res = req.request_get(path)
    res.code != '404'
  rescue StandardError
    false
  end

  def self.palladium_token?
    return true unless File.read("#{ENV['HOME']}/.palladium/token").strip.empty?

    false
  rescue Errno::ENOENT => e
    OnlyofficeLoggerHelper.log(e.to_s)
    false
  end
end
