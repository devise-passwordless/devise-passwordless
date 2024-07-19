require "rails_helper"

RSpec.describe "PasswordlessUser magic links", :type => :system do
  let(:email) { "foo@example.com" }
  let(:css_class) { "passwordless_user" }

  before do
    driven_by(:rack_test)
  end

  let(:user) { PasswordlessUser.create(email: email) }
  let(:token) { user.encode_passwordless_token }

  it "successfully logs in using magic link" do
    visit send("#{user.model_name.param_key}_magic_link_path", user.model_name.param_key => {email: user.email, token: token, remember_me: false})

    # It successfully logs in
    expect(page).to have_css("h2", text: "Sign-in status")
    expect(page).to have_css("p.#{css_class} span.email", text: user.email)
  end

  context "user already signed in" do
    let!(:user1) { PasswordlessUser.create(email: "user1@example.com") }
    let!(:user2) { PasswordlessUser.create(email: "user2@example.com") }

    it "signs out the current user and signs in as the new user when clicking a magic link" do
      # Log in via magic link for user1
      token1 = user1.encode_passwordless_token
      visit send("#{user1.model_name.param_key}_magic_link_path", user1.model_name.param_key => {email: user1.email, token: token1, remember_me: false})

      # Log in via magic link for user2
      token2 = user2.encode_passwordless_token
      visit send("#{user2.model_name.param_key}_magic_link_path", user2.model_name.param_key => {email: user2.email, token: token2, remember_me: false})

      # Check that we're now signed in as user2
      expect(page).to have_css("h2", text: "Sign-in status")
      expect(page).to have_css("p.passwordless_user span.email", text: user2.email)
      expect(page).not_to have_css("p.passwordless_user span.email", text: user1.email)
    end
  end
end
