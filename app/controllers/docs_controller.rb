class DocsController < ApplicationController
  def index
  end

  def create
    hider = SymbolsHider.new(params[:file])
    send_data hider.process_document, filename: hider.processed_filename, type: 'document/pdf'
  end
end
