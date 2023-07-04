require 'archivededup/filepicker'

RSpec.describe Archivededup::FilePicker do

  it "doesn't fail on zero-length names" do
    files= []
    
    f = Archivededup::FilePicker.new.pick(files)

    expect(f).to be_nil
  end

  it "picks longest name" do
    files= ['a', 'bb', 'c']
    
    f = Archivededup::FilePicker.new.pick(files)

    expect(f).to eq('bb')
  end

  it "picks dated name" do
    files= ['a', 'anice-file-that-is-very-long.png', 'anice-file-202102.png', 'c']
    
    f = Archivededup::FilePicker.new.pick(files)

    expect(f).to eq('anice-file-202102.png')
  end

  it "picks what I want 001" do
    files = [
      '/home/sam/Archive/Pictures/Chase - Age 1/Chase 1 to 2 months for Walgreens/P1030025.JPG',
      '/home/sam/Archive/Pictures/Christmas 2012/P1030025.JPG',
      '/home/sam/Archive/Pictures/Christmas 2012/best/P1030025.JPG',
    ]

    f = Archivededup::FilePicker.new.pick(files)

    expect(f).to eq('/home/sam/Archive/Pictures/Christmas 2012/best/P1030025.JPG')

  end

end