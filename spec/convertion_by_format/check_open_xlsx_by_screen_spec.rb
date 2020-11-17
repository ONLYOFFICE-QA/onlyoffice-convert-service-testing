# frozen_string_literal: true

require 'spec_helper'
FileHelper.clear_dir('files_tmp')
palladium = PalladiumHelper.new(DocumentServerHelper.get_version, 'Convert XLSX')
result_sets = palladium.get_result_sets(StaticData::POSITIVE_STATUSES)
files = s3.get_files_by_prefix('xlsx')
describe 'Convert docx files by convert service' do
  before :each do
    @image_size = nil
    @server_response = nil
  end
  (files - result_sets.map { |result_set| "xlsx/#{result_set}" }).each do |file_path|
    it File.basename(file_path) do
      skip 'https://bugzilla.onlyoffice.com/show_bug.cgi?id=38488' if file_path == 'xlsx/Smaller50MB.xlsx'
      skip 'Timeout error' if file_path == 'xlsx/Consolidation_employees.xlsx'
      skip 'Timeout error' if file_path == 'xlsx/Mo drinks.xlsx'
      skip 'Timeout error' if file_path == 'xlsx/MODELO_planilhaControleFinanceiro.xlsx'
      skip 'Timeout error' if file_path == 'xlsx/70000strings.xlsx'
      skip 'Timeout error' if file_path == 'xlsx/50000strings.xlsx'
      skip 'Timeout error' if file_path == 'xlsx/Hasil Treasure 2010 Season 2.xlsx'
      s3.download_file_by_name(file_path, './files_tmp')
      @server_response = converter.perform_convert(url: file_uri(file_path), outputtype: 'png')
      expect(@server_response[:url].nil?).to be_falsey
      expect(@server_response[:url].empty?).to be_falsey
      @image_size = ImageHelper.get_image_size(@server_response[:url])
      expect(@image_size).to be > StaticData::MIN_XLSX_IMAGE_SIZE
    end
  end

  after :each do |example|
    FileHelper.clear_dir('files_tmp')
    palladium.add_result_and_log(example, @image_size, @server_response[:data])
  end
end
