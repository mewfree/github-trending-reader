require 'nokogiri'
require 'net/http'
require 'redis'
require 'sinatra'
require 'slim'
require 'stylus'
require 'stylus/tilt'

# Initiating Redis
redis = Redis.new

# GitHub trending page's URI
uri = URI('https://github.com/trending')

get '/stylesheet.css' do
  stylus :stylesheet
end

get '/' do
  html = Net::HTTP.get(uri)
  page = Nokogiri::HTML(html)
  base = page.xpath('//ol/*/h3/a/@href')

  repos = []

  base.each do |repo|
    repo = repo.to_s
    split = repo.split('/')

    author = split[1]
    name = split[2]
    key = author+'/'+name
    link = 'https://github.com/'+key

    if (!redis.get(key))
      repos.push({ :key => key, :link => link })
      redis.setex(key, 30*24*60*60, '')
    end
  end

  @repos = repos
  slim :index
end
