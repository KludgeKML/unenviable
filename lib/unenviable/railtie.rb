module Unenviable
  # Adds hook to flag ENV calls outside of rails initialization
  class Railtie < Rails::Railtie
    initializer "unenviable.configure_rails_initialization" do
      Unenviable.install_wrapper
    end

    config.after_initialize do
      puts("IS RAILS INITIALISED? #{Rails.initialized?}")
      ENV.close_wrapper if ENV.respond_to?(:close_wrapper)
    end
  end
end
