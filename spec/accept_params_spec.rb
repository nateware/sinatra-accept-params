require File.expand_path 'spec_helper', File.dirname(__FILE__)

class Application < Sinatra::Base
  register Sinatra::AcceptParams

  set :raise_errors, false
  set :show_exceptions, false

  get '/search' do
    accept_params do |p|
      p.integer :page, :default => 1, :minvalue => 1
      p.integer :limit, :default => 20, :maxvalue => 100
      p.boolean :wildcard, :default => false
      p.string :search, :required => true
      p.float :timeout, :default => 3.5
    end
    params_dump
  end
  
  get '/users' do
    accept_no_params
  end
  
  get '/posts/:id' do
    accept_only_id
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
    last_response.body.should == %q(Request params missing required parameter 'search')

    get '/search', :page => 'Yes'
    last_response.status.should == 400
    last_response.body.should == %q(Value for parameter 'page' (Yes) is of the wrong type (expected integer))

    get '/search', :wildcard => 15
    last_response.status.should == 400
    last_response.body.should == %q(Value for parameter 'wildcard' (15) is of the wrong type (expected boolean))

    get '/search', :page => 0
    last_response.status.should == 400
    last_response.body.should == %q(Value for parameter 'page' (0) is less than minimum value (1))

    get '/search', :limit => 900000
    last_response.status.should == 400
    last_response.body.should == %q(Value for parameter 'limit' (900000) is more than maximum value (100))

    get '/search', :search => 'foot'
    last_response.status.should == 200
    last_response.body.should == "limit=20; page=1; search=foot; timeout=3.5; wildcard=false"

    get '/search', :search => 'taco grande', :wildcard => 'true'
    last_response.status.should == 200
    last_response.body.should == "limit=20; page=1; search=taco grande; timeout=3.5; wildcard=true"

    get '/search', :limit => 100, :wildcard => 0, :search => 'string', :timeout => '19.2433'
    last_response.status.should == 200
    last_response.body.should == "limit=100; page=1; search=string; timeout=19.2433; wildcard=false"

    get '/search', :a => 3, :b => 4, :search => 'bar'
    last_response.status.should == 400
    last_response.body.should == %q(Request included unexpected parameters: a, b)
  end
  
  it "should handle accept_no_params call" do
    get '/users', :limit => 1
    last_response.status.should == 400
    last_response.body.should == %q(Request included unexpected parameter: limit)

    get '/users'
    last_response.status.should == 200
  end
  

  it "should handle accept_only_id call" do
    get '/posts/blarp'
    last_response.status.should == 400
    last_response.body.should == %q(Value for parameter 'id' (blarp) is of the wrong type (expected integer))

    get '/posts/1'
    last_response.status.should == 200
  end
end
