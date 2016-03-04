class DocsController < ApplicationController
  def index
  end

  def show
  end

  def create
    hider = SymbolsHider.new(params[:file])
    binding.pry
  end
end
