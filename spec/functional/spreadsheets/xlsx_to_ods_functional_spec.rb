# frozen_string_literal: true

require './spec/spec_helper'
FileHelper.clear_dir 'files_tmp'
palladium = PalladiumHelper.new DocumentServerHelper.get_version, 'Xlsx to Ods'
result_sets = palladium.get_result_sets StaticData::POSITIVE_STATUSES
files = s3.files_from_folder('xlsx')
describe 'Convert xlsx to ods by convert service' do
  before do
    @metadata = nil
  end

  (files - result_sets.map { |result_set| "xlsx/#{result_set}" }).each do |file_path|
    it File.basename(file_path) do
      pending 'Need to increase the conversion timeout' if file_path == 'xlsx/Hasil Treasure 2010 Season 2.xlsx'
      skip 'File is too big' if file_path == 'xlsx/Smaller50MB.xlsx'
      s3.download_file_by_name(file_path, './files_tmp')
      @metadata = converter.perform_convert(url: file_uri(file_path), outputtype: 'ods')
      expect(@metadata[:url]).not_to be_nil
      expect(@metadata[:url]).not_to be_empty
      @metadata[:file_path] = FileHelper.download_file(@metadata[:url])
      expect(File).to exist(@metadata[:file_path])
    end
  end
  after do |example|
    FileHelper.clear_dir('files_tmp')
    palladium.add_result_and_log(example)
  end
end
