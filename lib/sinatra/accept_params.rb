
module Sinatra
  module AcceptParams
    # Exceptions for AcceptParams
    class ParamError < StandardError; end #:nodoc:
    class NoParamsDefined   < ParamError; end #:nodoc:
    class MissingParam      < ParamError; end  #:nodoc:
    class UnexpectedParam   < ParamError; end  #:nodoc:
    class InvalidParamType  < ParamError; end  #:nodoc:
    class InvalidParamValue < ParamError; end  #:nodoc:
    class SslRequired       < ParamError; end  #:nodoc:
    class LoginRequired     < ParamError; end  #:nodoc:
  
    # Below here are settings that can be modified in environment.rb
    # Whether or not to cache rules for performance.
    def self.cache_rules=(val); @@cache_rules = val; end
    def self.cache_rules; @@cache_rules; end
    self.cache_rules = false

    # The list of params that we should allow (but not require) by default. It's as if we
    # said that all requests may_have these elements. By default this
    # list is set to:
    #
    # * action
    # * controller
    # * commit
    # * _method
    #
    # You can modify this list in your environment.rb if you need to. Always
    # use strings, not symbols for the elements. Here's an example:
    #
    #   AcceptParams::ParamRules.ignore_params << "orientation"
    #
    def self.ignore_params=(val); @@ignore_params = val; end
    def self.ignore_params; @@ignore_params; end
    self.ignore_params = %w( action controller commit format _method authenticity_token )

    # The columns in ActiveRecord models that we should ignore by
    # default when expanding an is_a directive into a series of 
    # must_have directives for each attribute. These are the 
    # attributes that are almost never present in your forms (and hence your params).
    # By default this list is set to:
    #
    # * id
    # * created_at
    # * updated_at
    # * created_on
    # * updated_on
    # * lock_version
    #
    # You can modify this in your environment.rb if you have common attributes
    # that should always be ignored. Here's an example:
    #
    #   AcceptParams::ParamRules.ignore_columns << "deleted_at"
    #
    def self.ignore_columns=(val); @@ignore_columns = val; end
    def self.ignore_columns; @@ignore_columns; end
    self.ignore_columns = %w( id created_at updated_at created_on updated_on lock_version )

    # If unexpected params are encountered, default behavior is to raise an exception
    # Setting this to true will instead just all them on through.  Note this defeats
    # much of the purpose of the plugin. To mitigate security issues, try setting the
    # next flag to "true" if you set this to true.
    def self.ignore_unexpected=(val); @@ignore_unexpected = val; end
    def self.ignore_unexpected; @@ignore_unexpected; end
    self.ignore_unexpected = false

    # If unexpected params are encountered, remove them to prevent injection attacks.
    # Note: This is only relevant if you set ignore_unexpected to true, in which case
    # you can have them removed (safer) by setting this. The basic idea is that then
    # an exception won't be raised, but an attacker still won't be able to inject params.
    def self.remove_unexpected=(val); @@remove_unexpected = val; end
    def self.remove_unexpected; @@remove_unexpected; end
    self.remove_unexpected = false
  
    # How to validate parameters, if the person doesn't specify :validate
    def self.type_validations=(val); @@type_validations = val; end
    def self.type_validations; @@type_validations; end
    self.type_validations = {
      :integer => /^-?\d+$/,
      :float   => /^-?(\d*\.\d+|\d+)$/,
      :decimal => /^-?(\d*\.\d+|\d+)$/,
      :datetime => /^[-\d:T\s]+$/,  # "T" is for ISO date format
    }
    
    # Global on/off for SSL
    def self.ssl_enabled=(val); @@ssl_enabled = val; end
    def self.ssl_enabled; @@ssl_enabled; end
    self.ssl_enabled = true
  end
end

require 'sinatra/accept_params/param_rules'
require 'sinatra/accept_params/helpers'  # DSL for Sinatra
