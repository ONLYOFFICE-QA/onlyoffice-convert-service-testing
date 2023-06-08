# frozen_string_literal: true

require './spec/spec_helper'
FileHelper.clear_dir 'files_tmp'
palladium = PalladiumHelper.new DocumentServerHelper.get_version, 'Spreadsheets to All'
result_sets = palladium.get_result_sets StaticData::POSITIVE_STATUSES
files = JSON.load_file(File.join(Dir.pwd, 'assets', 'testing_files.json'))['spreadsheets']
output_formats = %w[bmp csv gif jpg ods ots pdf png xlsm xlsx xltm xltx]

describe 'Convert spreadsheets to all formats by convert service' do
  before do
    @metadata = nil
  end

  files.each do |file_path|
    output_formats.each do |format|
      test_name = "#{File.extname(file_path).delete('.')} to #{format}"
      next if result_sets.include?(test_name) || File.extname(file_path).delete('.') == format

      it test_name do
        s3.download_file_by_name(file_path, './files_tmp')
        result_path = "./files_tmp/#{File.basename(file_path)}.#{format}"
        @metadata = converter.perform_convert(url: file_uri(file_path), outputtype: format)
        expect(@metadata[:url]).not_to be_nil
        expect(@metadata[:url]).not_to be_empty
        FileHelper.download_file(@metadata[:url], result_path)
        expect(File).to exist(result_path)
      end
    end
  end

  after do |example|
    FileHelper.clear_dir('files_tmp')
    palladium.add_result_and_log(example)
  end
end
