class MagicLinkMailer < ApplicationMailer
  def sign_in_email(user, token)
    @user = user
    @token = token
    @magic_link = magic_link_url(token: @token)

    mail(
      to: @user.email,
      subject: "Votre lien de connexion"
    )
  end
end
