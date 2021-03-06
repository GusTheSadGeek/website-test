module PageModels
  class SignInForm < PageModels::BlinkboxbooksSection
    element :email, 'input#email'
    element :password, 'input#password'
    element :sign_in_button, 'button', :text => /Sign in/i
    element :show_password, '#showPassword'

    def submit(email, password)
      wait_until { all_there? }
      self.email.set email
      self.show_password.set true
      self.password.set password
      self.sign_in_button.click
    end

    def fill_in_password(password)
      self.password.set password
    end

    def click_sign_in_button
      wait_for_sign_in_button
      sign_in_button.click
    end
  end
end
