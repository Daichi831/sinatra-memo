require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

class Memo

  # jsonファイルを読み込む
  def self.read
    # jsonファイルが存在しなかったら"memo.json"を作成する
    unless File.exist?("memo.json")
    # "memo.json"を{"memos" => []}の保存形式にする
      Memo.save(memo_data = {"memos" => {}})
    end

    File.open("memo.json") do |data|
      JSON.load(data)
    end
  end

  # memo_dataの内容を保存する
  def self.save(memo_data)
    File.open("memo.json", 'w') do |v|
     JSON.dump(memo_data, v)
   end
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @title = 'topページ'
  @memo_data = Memo.read
  erb :top
end

get '/new' do
  @title = '新規作成ページ'
  erb :new
end

post '/memos' do
  # memo.jsonを開く（読み込み）
  memo_data = Memo.read

  # メモデータを追加する
  id = SecureRandom.uuid
  memo_data["memos"]["#{id}"] = {"title": params[:memo_title], "content": params[:memo_content]}
  # メモデータを保存する（書き込み）
  Memo.save(memo_data)

  redirect '/memos'
end

get '/memos/:id' do |id|
  @title = '詳細ページ'
  @id = id
  memo_data = Memo.read
  # idに紐付いたデータを格納する
  @memo = memo_data["memos"][@id]

  erb :show
end

delete '/memos/:id' do |id|
  @id = id
  memo_data = Memo.read
  memo = memo_data["memos"][@id]
  # データを削除
  memo_data["memos"].delete(@id)
  # 削除した結果を保存
  Memo.save(memo_data)  
  redirect '/memos'
end

patch '/memos/:id' do |id|
  @id = id
  memo_data = Memo.read
  # 更新データ
  edit_memo_data = {"title": params[:memo_title], "content": params[:memo_content]}
  # データの更新
  memo_data["memos"][@id].merge!(edit_memo_data)
  # データを保存
  Memo.save(memo_data)
  redirect '/memos'
end

get '/memos/:id/edit' do |id|
  @title = '編集ページ'
  @id = id
  memo_data = Memo.read
  memo = memo_data["memos"][@id]
  @edit_data = memo
  erb :edit
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end