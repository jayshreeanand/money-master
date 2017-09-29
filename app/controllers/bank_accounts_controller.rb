class BankAccountsController < ApplicationController
  before_action :authenticate_user!
  layout 'dashboard/main'

  def connect
  end

  def index
    @bank_accounts = current_user.bank_accounts
  end

  def show
    @bank_account = BankAccount.find(params[:id])
  end

  def sync
    current_user.bank_accounts.each do |bank_account|
      bank_account.sync_account_info
    end
    redirect_to bank_accounts_path
  end
end
