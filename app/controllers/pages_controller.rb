# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]
  helper_method :sort_column, :sort_direction, :sort_column_host

  def home
    @current_user = current_user
    @ioc = Ioc.new
  end

  def settings
    @forms = Form.all.order("#{sort_column} #{sort_direction}").page params[:page]
    @hosts = Host.all.order("#{sort_column_host} #{sort_direction}").page params[:page]
    @iocs = Ioc.official_url.order("#{sort_column} #{sort_direction}").page params[:page]

    return unless params[:query].present?

    sql_subquery = <<~SQL
      name ILIKE :query
    SQL
    @forms = @forms.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
    @hosts = @hosts.where(sql_subquery, query: "%#{params[:query]}%").page params[:page]
  end


  private

  def sort_column
    Form.column_names.include?(params[:sort]) ? params[:sort] : "url" # Defaults to url column
  end

  def sort_column_host
    Host.column_names.include?(params[:sort]) ? params[:sort] : "email" # Defaults to email column
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
