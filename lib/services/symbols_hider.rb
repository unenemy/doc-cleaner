class SymbolsHider
  CLEAR_SYMBOLS = ['a', 'e', 'i', 'o', 'u']

  attr_reader :processed_pdf_blob, :processed_pdf_filename

  def initialize(file, ignore_case=false, color='black')
    @file, @color = file, color
    @symbols_to_clear = CLEAR_SYMBOLS
    @symbols_to_clear += CLEAR_SYMBOLS.map(&:upcase) if ignore_case
    @processed_pdf_filename = File.basename(@file.original_filename, '.*') + '_cleared.pdf'
  end

  def process_document
    image_list = Magick::ImageList.new
    split_pdf_to_images.each{|image| image_list << process_image(image)}
    @processed_pdf_blob = image_list.to_blob do
      self.format = 'PDF'
    end
    clear_temporary_files
  end

  private
  def pdf_document_path
    case File.extname(@file.original_filename)
    when '.pdf'
      @file.tempfile.path
    else
      @temp_pdf = DocConverter.temporary_pdf_path_for(@file.tempfile.path)
    end
  end

  def split_pdf_to_images
    original_pdf = File.open(pdf_document_path, 'rb').read
    document_images = Magick::Image::from_blob(original_pdf) do
      self.format = 'PDF'
      self.quality = 100
      self.density = 144
    end
    document_images.map{|image| set_image_background(image)}
  end

  def set_image_background(image, color='white')
    list = Magick::ImageList.new
    list << image
    list.new_image(image.columns, image.rows){ self.background_color = color }
    image = list.reverse.flatten_images
    image.format = 'JPG'
    image.to_blob
    image
  end

  def process_image(image)
    @image = image
    chars = RTesseract::BoxChar.new(image).words
    chars.select!{|char| @symbols_to_clear.include? char[:char]}
    chars.each{|char| replace_char(char)}
    @image
  end

  def replace_char(char)
    gc = Magick::Draw.new
    gc.stroke = @color
    gc.fill = @color
    gc.rectangle char[:x_start], @image.rows - char[:y_start], char[:x_end], @image.rows - char[:y_end]
    gc.draw(@image)
  end

  def clear_temporary_files
    FileUtils.rm(@temp_pdf) if @temp_pdf
  end
end
