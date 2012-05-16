require './examples/web_server'

use Rack::ShowExceptions
use Rack::Reloader
use WebServer

run WebServer.new
