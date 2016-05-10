class StandardSetsController < ApplicationController
  include UuidReaders

  def create
    @standard_set = StandardSet.new(standard_set_params)
    if @standard_set.save
      redirect_to standard_set_path(@standard_set.friendly_uuid), notice: t('.success',count: @standard_set.standard_count)
    else
      flash.now.alert = @standard_set.errors.full_messages
      render :new
    end
  end

  def new
    @standard_set = StandardSet.new
    @standard_types = StandardType.alphabetical.pluck(:name,:id)
  end

  def index
    @standard_sets = StandardSet.latest_first.page(params[:page])
  end

  def show
    @standard_set = StandardSet.where(uuid:uuid_from_parameters).first!
    @standards = @standard_set.standards.include_for_list.page(params[:page])
    @subtitle = l(@standard_set.created_at, format: :long)
  end


  private

  def standard_set_params
    params.required(:standard_set).permit(:standard_count,:standard_type_id)
  end
end