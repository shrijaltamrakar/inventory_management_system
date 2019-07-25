class ItemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @q = Item.ransack(params[:q])
    @items = @q.result
    
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    @item.asset_code = get_asset_code(@item)
    if @item.save
      redirect_to items_path
    else
      render 'new'
    end
  end

  def show
    @item = Item.find(params[:id])
    if @item.user_id!=nil
      @user = User.find(@item.user_id).user_name
    else
      @user = "Not in Use"
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])

    if @item.update_attributes(item_params)
      redirect_to(item_path(@item))
    else
      render('edit')
    end
  end

  def delete
    @item = Item.find(params[:id])
  end
  
  def destroy
  end
  
  def use_request
    @item = Item.find(params[:id])
    users = @item.users
    users << current_user
    @item.users = users.uniq
    @item.save
    @use_request = UseRequestHistory.new
    @use_request.user = current_user.user_name
    @use_request.asset = @item.asset
    @use_request.save
    AssetMailer.use_request(@item,current_user).deliver!
    redirect_to(items_path)
  end
  
  def use_approve
    @item = Item.find(params[:id])
    @user = User.find(params[:user_id])
    AssetMailer.use_response(@item, @user, 1).deliver!
    @item.user_id = @user.id
    @item.users.delete(@user)
    @item.save
    @use_history = UseHistory.new
    @use_history.user = @user.user_name
    @use_history.asset = @item.asset
    @use_history.save
    
    redirect_to(items_path)
  end
  
  def use_decline
    @item = Item.find(params[:id])
    @user = User.find(params[:user_id])
    AssetMailer.use_response(@item, @user, 0).deliver!

    @item.users.delete(@user)
    @item.save
    redirect_to(items_path)
  end

  private

  def item_params
    params.require(:item).permit(:asset, :date_of_purchase, :category_id)
  end

  def get_asset_code(item)
    date = item.date_of_purchase
    code = item.asset + date.year.to_s + date.month.to_s + date.day.to_s 
  end
end
