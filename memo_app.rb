require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'dotenv/load'

get '/' do
  redirect '/memos'
end

def connect
  # データベースに接続する
  conn = PG::connect(host: ENV['DATABASE_HOST'], 
                      user: ENV['DATABASE_USER'], 
                      password: ENV['DATABASE_PASSWORD'], 
                      dbname: ENV['DATABASE_NAME'])
end

def list
  connect.exec("select * from Memos;")
end

def create(memo_title, memo_content)
  connect.exec("INSERT INTO Memos (title, content) VALUES ($1, $2);",[memo_title, memo_content])
end

def show(id)
  connect.exec("SELECT id, title, content FROM Memos WHERE id = $1;",[id])
end

def delete(id)
  connect.exec("DELETE FROM Memos WHERE id = $1;",[id])
end

def update(memo_title, memo_content, id)
  connect.exec("UPDATE Memos SET title = $1, content = $2 WHERE id = $3;",[memo_title, memo_content, id])
end

get '/memos' do
  @page_title = "トップページ"
  # 全データを取得するためSQL文を実行する
  @memos = list
  erb :top
end

get '/new' do
  @page_title = "新規作成ページ"
  erb :new
end

post '/memos' do
  # newページで入力された情報を受け取る
  @memo_title = params[:memo_title]
  @memo_content = params[:memo_content]
  # データベースに登録する
  create(@memo_title, @memo_content)
  redirect '/memos'
end

get '/memos/:id' do |id|
  @page_title = "詳細ページ"
  @id = id
  # idと同じ行のメモデータを選択する
  @memos = show(@id)
  erb :show
end

delete '/memos/:id' do |id|
  @id = id
  # idが一致した行のデータを削除
  delete(@id)
  redirect '/memos'
end

get '/memos/:id/edit' do |id|
  @page_title = "編集ページ"
  @id = id
  @memos = show(@id)
  erb :edit
end

patch '/memos/:id' do |id|
  @id = id
  @memo_title = params[:memo_title]
  @memo_content = params[:memo_content]
  update(@memo_title, @memo_content, @id)
  redirect '/memos'
end

# escape処理
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end