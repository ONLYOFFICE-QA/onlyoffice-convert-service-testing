# frozen_string_literal: true

require 'open-uri'
require 'tempfile'
require 'net/http'

# class with methods for working with files
class FileHelper
  # create test file in folder
  def self.create_file(filepath)
    FileUtils.touch(filepath)
  end

  def self.create_tmp_dir
    tmp_dir = File.join(StaticData::TMP_FOLDER, "tmp_#{Time.now.to_i}_#{rand(10_000)}")
    FileUtils.mkdir_p(tmp_dir)
    tmp_dir
  end

  # @param file_name [String] Accepts file name
  # @return [String] will return the generated name
  def self.file_rename(file_path)
    file_new_name = Time.now.nsec.to_s + File.extname(File.basename(file_path))
    File.rename(file_path, File.join(File.dirname(file_path), file_new_name))
    file_new_name
  end

  # The method checks the existence of the directory,
  # and if it does not exist, creates a new one using the name as a parameter
  # @param dir_name [String] Temp dir name
  # @return [nil]
  def self.check_temp_dir(dir_name)
    if File.exist? dir_name
      OnlyofficeLoggerHelper.log "Directory #{dir_name} exist?: true"
    else
      Dir.mkdir dir_name
      OnlyofficeLoggerHelper.log "Directory #{dir_name} created"
    end
  end

  def self.download_file(url, file_path)
    File.binwrite(file_path, Net::HTTP.get_response(URI(url)).body)
  end
end
