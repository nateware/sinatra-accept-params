# See http://www.sinatrarb.com/extensions.html
module Sinatra
  module AcceptParams
    module Helpers
      def accept_params(opts={}, &block) #:yields: param
        raise NoParamsDefined, "Missing block for accept_params" unless block_given?
        rules = ParamRules.new(opts)
        rules.validate_request(request, session)
        yield rules
        rules.validate(params)
      end

      # Shortcut functions to tighten up security further
      def accept_no_params(opts={})
        accept_params(opts) {}
      end

      def accept_only_id(opts={})
        accept_params(opts) do |p|
          p.integer :id, :required => true
        end
      end
    end
    
    # Needed to register params handling with Sinatra
    def self.registered(app)
      app.helpers AcceptParams::Helpers
      app.error Sinatra::AcceptParams::LoginRequired do
        headers["WWW-Authenticate"] = %(Basic realm="Login required")
        halt 401, "Authorization required"
      end
    end
  end

  register AcceptParams
end
