# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'
require 'securerandom'

def conn
  PG.connect(dbname: 'memo_db')
end

def load_memos
  conn.exec('SELECT * FROM memos ORDER BY id ASC')
end

def load_memo(id)
  memos = conn.exec_params('SELECT * FROM memos WHERE id = $1', [id])
  memos[0]
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
  id = SecureRandom.uuid
  conn.exec_params('INSERT INTO memos VALUES ($1, $2, $3)', [id, params[:title], params[:content]])
  redirect "/memos/#{id}"
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
  conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3',
                   [params[:title], params[:content], params[:id]])
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  @memos = conn.exec_params('DELETE FROM memos WHERE id = $1', [params[:id]])
  redirect '/memos'
end
