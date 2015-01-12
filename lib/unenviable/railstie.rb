module Unenviable
  # Adds hook to flag ENV calls outside of rails initialization
  class Railstie < Rails::Railtie
    config.after_initialize do
      ENV.close_wrapper if ENV.respond_to?(:close_wrapper)
    end
  end
end
