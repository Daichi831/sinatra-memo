require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

class Memo
  # jsonファイルを読み込む
  def self.read
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
  # jsonファイルが存在しなかったら"memo.json"を作成する
  unless File.exist?("memo.json")
    # "memo.json"を{"memos" => []}の保存形式にする
    Memo.save(memo_data = {"memos" => []})
  end
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

  # メモデータをadd_memo_dataにいれる
  id = SecureRandom.uuid
  add_memo_data = {"#{id}" => {"title": params[:memo_title], "content": params[:memo_content]}}
  memo_data["memos"].push(add_memo_data)

  # メモデータを保存する（書き込み）
  Memo.save(memo_data)

  redirect '/memos'
end

get '/memos/:id' do |id|
  @title = '詳細ページ'
  @id = id
  memo_data = Memo.read

  memo_data["memos"].each do |one_data|
    # idに紐付いたメモデータをone_memo_dataにいれる
    if @one_memo_data == nil
       @one_memo_data = one_data[@id]
    end
  end

  erb :show
end

delete '/memos/:id' do |id|
  @id = id
  memo_data = Memo.read

  # URIのidと一致したハッシュを削除する
  memo_data["memos"].each do |one_data|
    one_data.delete_if {|memo_id| memo_id == @id}
  end
  # 削除した結果を保存
  Memo.save(memo_data)  
  redirect '/memos'
end

patch '/memos/:id' do |id|
  @id = id
  memo_data = Memo.read
  edit_memo_data = { @id => {"title": params[:memo_title], "content": params[:memo_content]}}
  memo_data["memos"].each do |one_data|
    one_data.each do |memo_id, memo|
      # idがあるものだけ書き換え処理を行う
      if memo_id == @id
        
        # one_dataの既存データを書き換える
        one_data.merge!(edit_memo_data)
      end
    end
  end
  # データを保存
  Memo.save(memo_data)
  redirect '/memos'
end

get '/memos/:id/edit' do |id|
  @title = '編集ページ'
  @id = id
  memo_data = Memo.read

  memo_data["memos"].each do |one_data|
    # idに紐付いたメモデータをedit_dataにいれる
    if @edit_data == nil
       @edit_data = one_data[@id]
    end
  end
  erb :edit
end