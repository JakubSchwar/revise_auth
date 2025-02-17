class ReviseAuth::PasswordResetsController < ReviseAuthController
  before_action :set_user, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    if (user = User.find_by(email: user_params[:email]))
      token = user.generate_token_for(:password_reset)
      ReviseAuth::Mailer.with(user: user, token: token).password_reset.deliver_later
    end

    flash[:notice] = I18n.t("revise_auth.password_reset_sent")
    redirect_to login_path
  end

  def edit
  end

  def update
    if @user.update(password_params)
      flash[:notice] = I18n.t("revise_auth.password_changed")
      redirect_to login_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by_token_for(:password_reset, params[:token])

    return if @user.present?

    flash[:alert] = I18n.t("revise_auth.password_link_invalid")
    redirect_to new_password_reset_path
  end

  def user_params
    params.require(:user).permit(:email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
