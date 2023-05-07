# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'securerandom'

def load_memos
  json_data = File.open('memos.json') { |file| JSON.parse(file.read) }
  json_data['memos']
end

def load_memo(id)
  memos = load_memos
  memos.find { |memo| memo['id'] == id }
end

def save_memos(memos)
  File.open('memos.json', 'w') { |file| JSON.dump({ 'memos' => memos }, file) }
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
  @memos = load_memos
  erb :memos
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  title = params[:title]
  text = params[:text]
  id = SecureRandom.uuid
  new_memo = { 'id' => id, 'title' => title, 'text' => text }

  memos = load_memos
  memos << new_memo
  save_memos(memos)

  redirect "/memos/#{new_memo['id']}"
end

get '/memos/:id' do
  @memo = load_memo(params[:id])
  erb :show_memo
end

get '/memos/:id/edit' do
  @memo = load_memo(params[:id])
  erb :edit_memo
end

patch '/memos/:id' do
  memos = load_memos
  target_memo = memos.find { |memo| memo['id'] == params[:id] }

  target_memo['title'] = params[:title]
  target_memo['text'] = params[:text]
  save_memos(memos)

  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = load_memos

  memos.delete_if do |memo|
    memo['id'] == params[:id]
  end
  save_memos(memos)

  redirect '/memos'
end
