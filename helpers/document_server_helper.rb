# frozen_string_literal: true

class DocumentServerHelper
  def self.get_version
    get_version_from_sdk_all("#{StaticData.documentserver_url}/sdkjs/word/sdk-all.js")
  end

  def self.get_version_from_sdk_all(sdk_all_link)
    starting_lines = `curl --compressed -m 10 --insecure -r 0-300 #{sdk_all_link} 2>/dev/null`
    trimmed_lines = starting_lines[0..300]
    trimmed_lines[/(\w+.)?\w+.\w+\s\(build:.*\)/]
  end

  # @return [OnlyofficeDocumentserverConversionHelper::ConvertFileData]
  def self.no_jwt_converter
    OnlyofficeDocumentserverConversionHelper::ConvertFileData.new(StaticData.documentserver_url)
  end

  # @return [OnlyofficeDocumentserverConversionHelper::ConvertFileData]
  def self.jwt_from_env_converter
    OnlyofficeDocumentserverConversionHelper::ConvertFileData.new(StaticData.documentserver_url,
                                                                  jwt_key: ENV.fetch('DOCUMENTSERVER_JWT'))
  end

  # @return [OnlyofficeDocumentserverConversionHelper::ConvertFileData]
  def self.jwt_from_file_converter
    OnlyofficeDocumentserverConversionHelper::ConvertFileData.new(StaticData.documentserver_url,
                                                                  jwt_key: StaticData.get_jwt_key.strip)
  end
end
