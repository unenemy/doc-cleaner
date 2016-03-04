class DocsController < ApplicationController
  def index
  end

  def create
    hider = SymbolsHider.new(params[:file])
    hider.process_document
    send_data hider.processed_pdf_blob, filename: hider.processed_pdf_filename, type: 'document/pdf'
  end
end
