require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'securerandom'

include ERB::Util

helpers do
  def h(text)
    escape_html(text)
  end
end

not_found do
  status 404
  erb :not_found
end

get "/memos" do
  hash = File.open('memos.json') { |file| JSON.parse(file.read) }
  memos = hash["memos"]
  @title = memos.map{|memo| memo["title"]}
  @id = memos.map{|memo| memo["id"]}
  erb :memos
end

get "/memos/new" do
  erb :new_memo
end

post "/memos" do
    @title = params[:title]
    @text = params[:text]
    @id = SecureRandom.uuid 
    hash = File.open('memos.json') { |file| JSON.parse(file.read) }
      hash["memos"] << {"id" => @id, "title" => @title, "text" => @text}
      File.open("memos.json", "w") { |file| JSON.dump(hash, file) }
      redirect '/memos'
end

get "/memos/:id" do
  hash = File.open('memos.json') { |file| JSON.parse(file.read) }
  memos = hash["memos"]
  @title = memos.map{|memo| memo["title"]}
  @text = memos.map{|memo| memo["text"]}
  @id = memos.map{|memo| memo["id"]}
  erb :show_memo
end


get "/memos/:id/edit" do
  hash = File.open('memos.json') { |file| JSON.parse(file.read) }
  memos = hash["memos"]
  @title = memos.map{|memo| memo["title"]}
  @text = memos.map{|memo| memo["text"]}
  @id = memos.map{|memo| memo["id"]}
  erb :edit_memo
end

patch "/memos/:id" do
  hash = File.open('memos.json') { |file| JSON.parse(file.read) }
  memos = hash["memos"]
  @title = params[:title]
  @text = params[:text]
  @id = params[:id]
  memo = memos.find { |memo| memo['id'] == @id }
  memo['title'] = @title
  memo['text'] = @text if memo

  File.open("memos.json", "w") { |file| JSON.dump(hash, file) }
  redirect '/memos'
end

delete "/memos/:id" do
  hash = File.open('memos.json') { |file| JSON.parse(file.read) }
  memos = hash["memos"]
  @id = memos.map{|memo| memo["id"]}
  memos.delete_if do |memo|
    memo["id"] == params[:id]
  end
  File.open("memos.json", "w") { |file| JSON.dump(hash, file) }
  redirect '/memos'
end
