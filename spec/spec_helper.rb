require 'rubygems'
require 'bacon'
require 'rack/test'

$LOAD_PATH.unshift(File.expand_path File.dirname(__FILE__))
$LOAD_PATH.unshift(File.expand_path File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sinatra'
require 'sinatra/accept_params'

Bacon.summary_on_exit

def params_dump
  params.keys.sort.collect{|k| "#{k}=#{params[k]}"} * '; '
end
