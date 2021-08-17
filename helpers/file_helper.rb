# frozen_string_literal: true

# class with methods for working with files
class FileHelper
  # delete all files and folders from dir
  def self.clear_dir(dir)
    FileUtils.rm_rf("#{dir}/.", secure: true)
  end

  # create test file in folder
  def self.create_file(filepath)
    FileUtils.touch(filepath)
  end

  # @param file_name [String] Accepts file name
  # @return [String] will return the generated name
  def self.file_rename(file_name)
    file_new_name = Time.now.nsec.to_s + File.extname(file_name)
    File.rename("files_tmp/#{file_name}", "files_tmp/#{file_new_name}")
    file_new_name
  end

  def self.dir_check_or_create(dir_name)
    if File.exist? dir_name.to_s
      puts 'files_tmp exist: true'
    else
      Dir.mkdir dir_name.to_s
    end
    true
  end
end
