class SymbolsHider
  CLEAR_SYMBOLS = ['a', 'e', 'i', 'o', 'u']

  attr_accessor :chars

  def initialize(file, case_sensitive = true)
    @file = file
    @symbols_to_clear = CLEAR_SYMBOLS
    @symbols_to_clear += CLEAR_SYMBOLS.map(&:upcase) unless case_sensitive
  end

  def process_document
    docoment = document_pdf_path
    pages = ['test.jpg', 'test.jpg']
    image_list = Magick::ImageList.new
    pages.each{|x| image_list << process_page(x)}
    image_list.write('result.pdf')
  end

  def document_pdf_path
    case File.extname(@file.original_filename)
    when '.pdf'
      @file.tempfile.path
    else
      nil
    end
  end

  def process_page(filename)
    chars = RTesseract::BoxChar.new(filename).words
    @chars = chars.select{|x| @symbols_to_clear.include? x[:char]}
    @image = Magick::Image.read(filename).first
    @chars.each{|char| replace_char(char)}
    @image.write "result.jpg"
    @image
  end

  def replace_char(char)
    gc = Magick::Draw.new
    gc.stroke = 'white'
    gc.fill = 'white'
    gc.rectangle char[:x_start], @image.rows - char[:y_start], char[:x_end], @image.rows - char[:y_end]
    gc.draw(@image)
  end
end
