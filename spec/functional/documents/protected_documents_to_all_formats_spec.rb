# frozen_string_literal: true

require './spec/spec_helper'
FileHelper.clear_dir 'files_tmp'
palladium = PalladiumHelper.new DocumentServerHelper.get_version, 'Protected Documents to All'
result_sets = palladium.get_result_sets StaticData::POSITIVE_STATUSES
files = JSON.load_file(File.join(Dir.pwd, 'assets', 'testing_files.json'))['protected_documents']
output_formats = JSON.load_file(File.join(Dir.pwd, 'assets', 'output_formats.json'))

describe 'Convert protected documents to all formats by convert service' do
  before do
    @metadata = nil
  end

  files.each do |file_path|
    input_format = File.extname(file_path).delete('.').to_s
    formats = output_formats.key?(input_format) ? output_formats[input_format] : output_formats['documents']

    formats.each do |format|
      test_name = "#{input_format} to #{format}"
      next if result_sets.include?(test_name) || input_format == format

      it test_name do
        s3.download_file_by_name(file_path, './files_tmp')
        result_path = "./files_tmp/#{File.basename(file_path)}.#{format}"
        password = File.basename(file_path).match(/\[pass(\d+)\]/)[1]
        @metadata = converter.perform_convert(url: file_uri(file_path), outputtype: format, password: password)
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
