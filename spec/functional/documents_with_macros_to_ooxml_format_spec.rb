# frozen_string_literal: true

require './spec/spec_helper'
require 'nokogiri'

FileHelper.clear_dir 'files_tmp'
palladium = PalladiumHelper.new DocumentServerHelper.get_version, 'Documents With Macros to Ooxml'
result_sets = palladium.get_result_sets StaticData::POSITIVE_STATUSES
files = JSON.load_file(File.join(Dir.pwd, 'assets', 'testing_files.json'))['documents_with_macros']

describe 'Convert documents with macros to ooxml format by convert service' do
  before do
    @metadata = nil
  end

  files.each do |file_path|
    input_format = File.extname(file_path).delete('.').to_s

    test_name = "#{input_format} with macros to ooxml"
    next if result_sets.include?(test_name)

    it test_name do
      s3.download_file_by_name(file_path, './files_tmp')
      @metadata = converter.perform_convert(url: file_uri(file_path), outputtype: 'ooxml')[:data]
      data = Nokogiri::XML(@metadata)
      expect(data.at('FileResult/FileUrl').text).not_to be_nil
      expect(data.at('FileResult/FileUrl').text).not_to be_empty
      expect(data.at('FileResult/FileType').text).to end_with('m')
      result_path = "./files_tmp/#{File.basename(file_path)}.#{data.at('FileResult/FileType').text}"
      FileHelper.download_file(data.at('FileResult/FileUrl').text, result_path)
      expect(File).to exist(result_path)
    end
  end

  after do |example|
    FileHelper.clear_dir('files_tmp')
    palladium.add_result_and_log(example)
  end
end
