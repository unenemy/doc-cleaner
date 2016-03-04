class DocConverter
  SOFFICE_PATH = '/Users/dh/Applications/LibreOffice.app/Contents/MacOS/soffice'

  def self.temporary_pdf_path_for(file)
    target_path = "tmp/" + SecureRandom.hex + ".pdf"
    Libreconv.convert(file, target_path, SOFFICE_PATH)
    target_path
  end
end
