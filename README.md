Sinatra::AcceptParams - Parameter whitelisting for Sinatra
==========================================================

This plugin adds parameter whitelisting, type checking, and validation at the routing level
to a Sinatra application.  While model-level validations are good for CRUD operations, in many
cases there are other input parameters which are either not part of a model, or which you want to
verify before executing lots of (potentially unsafe) code just to have your model raise an
error.  Examples include:

* page numbers for pagination
* search strings
* routing prefixes such as region or language

In addition, this plugin provides several extended capabilities which come in handy:

* type checking of parameters (eg, integers vs strings)
* automatic type casting of parameters (helps with plugins such as `will_paginate`)
* default values and post-processing of params

Example
-------

    # GET /channels
    # GET /channels.xml
    def index
      accept_params do |p|
        p.integer :page, :default => 1, :minvalue => 1
        p.integer :per_page, :default => 50, :minvalue => 1
      end
    end


    # POST /rating
    # POST /rating.xml
    def create
      accept_params do |p|
        p.namespace :rating do |p|
          p.integer :user_id, :required => true, :minvalue => 1
          p.integer :rating,  :required => true
          p.string  :comments, :process => Proc.new(value){ my_value_cleaner(value) }  # return filtered value
        end
      end
  
      @rating = Rating.new(params[:rating])
      @rating.save
      
      # format/response code
    end
  

    # GET /players/1
    # GET /players/1.xml
    def show
      accept_only_id
      @player = Player.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @player }
      end
    end


Author
------
Copyright (c) 2008-2010 [Nate Wiger](http://nateware.com).  All Rights Reserved.
This code is released under the Artistic License.

