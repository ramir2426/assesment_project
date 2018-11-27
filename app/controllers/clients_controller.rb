class ClientsController < ApplicationController

  def index
    @clients = current_user.clients.page(params[:page])
    redirect_to action: :new if @clients.empty?
  end

  def edit
    @client = current_user.clients.where(id: params[:id]).first
  end

  def update
    client = current_user.clients.where(id: params[:id]).first.tap { |c| c.update_attributes(client_params) }
    redirect_to clients_path
  end

  def new
    @client = Client.new(currency: 'USD')
  end

  def create
    @client = Client.create(client_params.merge(user: current_user))

    if @client.save
      redirect_to clients_path
    else
      render :new
    end
  end

  def destroy
    current_user.clients.where(id: params[:id]).first.destroy
    redirect_to clients_path
  end

private

  def client_params
    params.require(:client).permit(
      :business_name,
      :contact_name,
      :email,
      :business_address,
      :currency,
      :company_size
    )
  end
end
