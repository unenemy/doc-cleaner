class DocConverter
  def self.temporary_pdf_path_for(file)
    target_path = "tmp/" + SecureRandom.hex + ".pdf"
    Libreconv.convert(file, target_path, Rails.application.secrets.soffice_path)
    target_path
  end
end
