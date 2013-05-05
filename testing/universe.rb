require 'sinatra'
require 'yaml'
require 'json'
require 'open-uri'

# https://raw.github.com/kryonic/container_plugin/master/plugin.yaml

$index = YAML.load_file("index.yaml") || {}

get "/" do
  erb :index
end

get "/fetch" do
  packages = params[:packages].split(",")

  result = {}

  packages.each do |package|
    result[package] = $index[package]
  end

  content_type :json
  result.to_json
end

get "/package/:id" do
  plugin = $index[params[:id]]

  # Get user and repository names from URL
  plugin =~ /.*github.com\/([\w]+)\/([\w]+).*/
  puts $1
  puts $2

  # Fetch latest data
  contents = open("https://raw.github.com/#{$1}/#{$2}/master/plugin.yaml") { |f| f.read }

  # Convert to JSON
  content_type :json
  YAML.load(contents).to_json
end

post "/upload" do 
  plugin = YAML.load(params['myfile'][:tempfile])

  # Update plugin
  $index[plugin["name"]] = plugin["git"]

  # Save index
  File.write("index.yaml", $index.to_yaml)
end