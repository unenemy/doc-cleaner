class SymbolsHider
  CLEAR_SYMBOLS = ['a', 'e', 'i', 'o', 'u']

  attr_accessor :chars

  def initialize(file, case_sensitive=true, color='black')
    @file, @color = file, color
    @symbols_to_clear = CLEAR_SYMBOLS
    @symbols_to_clear += CLEAR_SYMBOLS.map(&:upcase) unless case_sensitive
  end

  def process_document
    image_list = Magick::ImageList.new
    document_images = split_pdf_to_images
    document_images.each_with_index{|x, i| image_list << process_image(x, i)}
    image_list.to_blob do
      self.format = 'PDF'
    end
  end

  def pdf_document_path
    case File.extname(@file.original_filename)
    when '.pdf'
      @file.tempfile.path
    else
      'pdf_man.pdf'
    end
  end

  def split_pdf_to_images
    original_pdf = File.open(pdf_document_path, 'rb').read
    document_images = Magick::Image::from_blob(original_pdf) do
      self.format = 'PDF'
      self.quality = 100
      self.density = 144
    end
    document_images.map{|image|
      list = Magick::ImageList.new
      list << image
      list.new_image(image.columns, image.rows){ self.background_color = 'white' }
      image = list.reverse.flatten_images
      image.format = 'JPG'
      image.to_blob
      image
    }
  end

  def processed_filename
    File.basename(@file.original_filename, '.*') + '_cleared.pdf'
  end

  def process_image(image, i)
    chars = RTesseract::BoxChar.new(image).words
    @chars = chars.select{|x| @symbols_to_clear.include? x[:char]}
    @image = image
    @chars.each{|char| replace_char(char)}
    @image
  end

  def replace_char(char)
    gc = Magick::Draw.new
    gc.stroke = @color
    gc.fill = @color
    gc.rectangle char[:x_start], @image.rows - char[:y_start], char[:x_end], @image.rows - char[:y_end]
    gc.draw(@image)
  end
end
