require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'dotenv/load'

get '/' do
  redirect '/memos'
end

def load(sql)
  # データベースに接続する
  @conn = PG::connect(host: ENV['DATABASE_HOST'], 
                      user: ENV['DATABASE_USER'], 
                      password: ENV['DATABASE_PASSWORD'], 
                      dbname: ENV['DATABASE_NAME'])
  memos = @conn.exec(sql)
  @conn.finish
  memos
end

get '/memos' do
  @page_title = "トップページ"
   # 全データを取得するためSQL文を実行する
   @memos = load("select * from Memos;")
  erb :top
end

get '/new' do
  @page_title = "新規作成ページ"
  erb :new
end

post '/memos' do
  # newページで入力された情報を受け取る
  memo_title = params[:memo_title]
  memo_content = params[:memo_content]
  # データベースに登録する
  sql = "INSERT INTO Memos (title, content) VALUES ('#{memo_title}', '#{memo_content}');"
  @memos = load(sql)

  redirect '/memos'
end

get '/memos/:id' do |n|
  @page_title = "詳細ページ"
  # idと同じ行のメモデータを選択する
  @memos = load("SELECT id, title, content FROM Memos WHERE id = '#{n}';")
  erb :show
end

delete '/memos/:id' do |n|
  # idが一致した行のデータを削除
  sql = "DELETE FROM Memos WHERE id = '#{n}';"
  load(sql)
  redirect '/memos'
end

get '/memos/:id/edit' do |n|
  @page_title = "編集ページ"
  sql = "SELECT id, title, content FROM Memos WHERE id = '#{n}';"
  @memos = load(sql)
  erb :edit
end

patch '/memos/:id' do |n|
  memo_title = params[:memo_title]
  memo_content = params[:memo_content]
  sql = "UPDATE Memos SET title = '#{memo_title}', content = '#{memo_content}' WHERE id = '#{n}';"
  @memos = load(sql)
  redirect '/memos'
end

# escape処理
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end