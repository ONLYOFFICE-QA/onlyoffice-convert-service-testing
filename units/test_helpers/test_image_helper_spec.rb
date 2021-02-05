# frozen_string_literal: true

describe ImageHelper do
  it 'add a file smaller than 10 KB' do
    url_image = 'https://user-images.githubusercontent.com/60688343/86939678-8c12bb80-c14a-11ea-97d4-e07c6e779b8a.png'
    expect(described_class.get_image_size(url_image.to_s)).to eq(4637)
  end

  it 'add a file larger than 10 KB' do
    url_image = 'https://user-images.githubusercontent.com/60688343/86939699-959c2380-c14a-11ea-8d31-337163799021.png'
    expect(described_class.get_image_size(url_image.to_s)).to eq(17_129)
  end
end
