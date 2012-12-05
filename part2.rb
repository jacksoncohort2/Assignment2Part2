require 'rubygems'
require 'sinatra'
require 'mongo'
require 'mongo_mapper'

MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = 'ipDB'

class IPInfo
  include MongoMapper::Document
  key :ipAddress, String
  timestamps!
end

get '/' do

  thisRequest = IPInfo.new(:ipAddress => request.ip)
  thisRequest.save

  a = IPInfo.collection.group({:keyf => "function(thisItem) { return { ipAddress: thisItem.ipAddress, thisYear: thisItem.created_at.getFullYear(), thisMonth: thisItem.created_at.getMonth(), thisDay: thisItem.created_at.getDate() }; }", :reduce => "function( current, output ) { output.counter++; }", :initial => { :counter => 0 } });

  b = "Hello World" + "\n"
  JSON.parse(a.to_json).each do |item|
    b = b + (item['thisMonth']+1).to_int.to_s + "-" + item['thisDay'].to_int.to_s + "-" + item['thisYear'].to_int.to_s + " = " + item['counter'].to_int.to_s + "\n"
  end

  b

end
