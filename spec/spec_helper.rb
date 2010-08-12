require 'rubygems'
require 'bacon'
require 'rack/test'

$LOAD_PATH.unshift(File.expand_path File.dirname(__FILE__))
$LOAD_PATH.unshift(File.expand_path File.join(File.dirname(__FILE__), '..', 'lib'))
require 'sinatra'
require 'sinatra/accept_params'

Bacon.summary_on_exit
