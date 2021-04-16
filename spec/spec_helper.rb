# frozen_string_literal: true

require 'bundler/setup'
require 'addressable'
require 'uri'
require 'onlyoffice_s3_wrapper'
require 'onlyoffice_documentserver_conversion_helper'
require 'onlyoffice_logger_helper/logger_helper'
require_relative '../config/StaticData'
require_relative '../helpers/document_server_helper'
require_relative '../helpers/file_helper'
require_relative '../helpers/image_helper'
require_relative '../helpers/palladium_helper'
require_relative '../helpers/pretests_check'

# ENV['DOCUMENTSERVER'] = ''
# ENV['NGINX'] = ''
# ENV['USE_JWT'] = 'no'

PretestsCheck.pretests_check

def s3
  @s3 ||= OnlyofficeS3Wrapper::AmazonS3Wrapper.new(bucket_name: 'conversion-testing-files', region: 'us-east-1')
end

RSpec.configure do |config|
  def converter
    @converter ||= if !StaticData::JWT_ENABLE
                     OnlyofficeDocumentserverConversionHelper::ConvertFileData.new(StaticData.documentserver_url)
                   elsif StaticData.jwt_data_exist?
                     OnlyofficeDocumentserverConversionHelper::ConvertFileData.new(StaticData.documentserver_url,
                                                                                   jwt_key: StaticData.get_jwt_key.strip)
                   end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# Method returns uri taking the path to the file
# @param file_path [String] Accepts relative path to file
# @return [String] URI address file in nginx
# @note Changes the name of a temporary file
def file_uri(file_path)
  tmp_name = FileHelper.file_rename(File.basename(file_path))
  link = "#{StaticData.nginx_url}/#{tmp_name}"
  Addressable::URI.parse(link).normalize.to_s
end
