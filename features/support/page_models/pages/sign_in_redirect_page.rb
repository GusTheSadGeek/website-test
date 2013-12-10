module PageModels
  class SignInRedirectPage < PageModels::BlinkboxbooksPage
    set_url "/#!/signin?redirectTo="
    set_url_matcher /signin\?redirectTo\=/
    element :register_button, "button", :text => "Register"
    section :sign_in_form, SignInForm, "#signin"
  end

  register_model_caller_method(SignInRedirectPage)
end