# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'securerandom'

def load_memos
  File.open('memos.json') { |file| JSON.parse(file.read) }
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

not_found do
  status 404
  erb :not_found
end

get '/memos' do
  hash = load_memos
  @memos = hash['memos']
  erb :memos
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  title = params[:title]
  text = params[:text]
  id = SecureRandom.uuid
  hash = load_memos
  hash['memos'] << { 'id' => id, 'title' => title, 'text' => text }
  File.open('memos.json', 'w') { |file| JSON.dump(hash, file) }
  redirect "/memos/#{id}"
end

get '/memos/:id' do
  hash = load_memos
  memos = hash['memos']
  @memo = memos.find { |m| m['id'] == params[:id] }
  erb :show_memo
end

get '/memos/:id/edit' do
  hash = load_memos
  memos = hash['memos']
  @memo = memos.find { |m| m['id'] == params[:id] }
  erb :edit_memo
end

patch '/memos/:id' do
  hash = load_memos
  memos = hash['memos']
  memo = memos.find { |m| m['id'] == params[:id] }
  memo['title'] = params[:title]
  memo['text'] = params[:text]
  File.open('memos.json', 'w') { |file| JSON.dump(hash, file) }
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  hash = load_memos
  memos = hash['memos']
  memos.delete_if do |memo|
    memo['id'] == params[:id]
  end
  File.open('memos.json', 'w') { |file| JSON.dump(hash, file) }
  redirect '/memos'
end
