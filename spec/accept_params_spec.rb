require File.expand_path 'spec_helper', File.dirname(__FILE__)

class Application < Sinatra::Base
  register Sinatra::AcceptParams

  set :raise_errors, false
  set :show_exceptions, false
  # Have to enumerate errors, because Sinatra uses is_a? test, not inheritance
  [ Sinatra::AcceptParams::ParamError,
    Sinatra::AcceptParams::NoParamsDefined,
    Sinatra::AcceptParams::MissingParam,
    Sinatra::AcceptParams::UnexpectedParam,
    Sinatra::AcceptParams::InvalidParamType,
    Sinatra::AcceptParams::InvalidParamValue,
    Sinatra::AcceptParams::SslRequired,
    Sinatra::AcceptParams::LoginRequired ].each do |cl|
    error cl do
      halt 400, 'bad params'
    end
  end

  get '/search' do
    accept_params do |p|
      p.integer :limit, :default => 20
      p.string :search, :required => true
    end
  end

end

class Bacon::Context
  include Rack::Test::Methods
  def app
    Application  # our application
  end
end

describe "Sinatra::AcceptParams" do
  it "should provide settings to control the lib" do
    Sinatra::AcceptParams.cache_rules.should == false
    Sinatra::AcceptParams.cache_rules = true
    Sinatra::AcceptParams.cache_rules.should == true
    Sinatra::AcceptParams.cache_rules = false
    Sinatra::AcceptParams.cache_rules.should == false

    Sinatra::AcceptParams.ignore_params.should == %w( action controller commit format _method authenticity_token )
    Sinatra::AcceptParams.ignore_params << 'ricky_bobby'
    Sinatra::AcceptParams.ignore_params.should == %w( action controller commit format _method authenticity_token ricky_bobby )

    Sinatra::AcceptParams.ignore_columns.should == %w( id created_at updated_at created_on updated_on lock_version )
    Sinatra::AcceptParams.ignore_columns << 'shake_and_bake'
    Sinatra::AcceptParams.ignore_columns.should == %w( id created_at updated_at created_on updated_on lock_version shake_and_bake )

    Sinatra::AcceptParams.ignore_unexpected.should == false
    Sinatra::AcceptParams.ignore_unexpected = true
    Sinatra::AcceptParams.ignore_unexpected.should == true
    Sinatra::AcceptParams.ignore_unexpected = false
    Sinatra::AcceptParams.ignore_unexpected.should == false

    Sinatra::AcceptParams.remove_unexpected.should == false
    Sinatra::AcceptParams.remove_unexpected = true
    Sinatra::AcceptParams.remove_unexpected.should == true
    Sinatra::AcceptParams.remove_unexpected = false
    Sinatra::AcceptParams.remove_unexpected.should == false

    Sinatra::AcceptParams.type_validations[:cal_jr] = /ricky_bobby/
    Sinatra::AcceptParams.type_validations[:cal_jr].should == /ricky_bobby/

    Sinatra::AcceptParams.ssl_enabled.should == true
    Sinatra::AcceptParams.ssl_enabled = false
    Sinatra::AcceptParams.ssl_enabled.should == false
    Sinatra::AcceptParams.ssl_enabled = true
    Sinatra::AcceptParams.ssl_enabled.should == true
  end
  
  it "should handle accept_params blocks" do
    get '/search'
    last_response.status.should == 400

    get '/search', :search => 'foot'
    last_response.status.should == 200
  end
end
