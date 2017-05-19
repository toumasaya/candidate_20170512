# Votes app notes

使用 Rails 實做可以投票的 APP。

## 建立一個新的 APP

使用 `rails new <app_name>` 指令建立一個 APP，並且進入到 APP 目錄：

```shell
$ rails new candidate
$ cd candidate
```

初始化 Git:

```shell
$ git init
$ git add -A
$ git commit -m "Initial commit"
```

使用 `rails server` 可以在 `localhost:3000` 看到歡迎畫面。

## 投票基本功能

- 可以建立候選人的資訊
  - 姓名（name）
  - 政黨（party）
  - 年齡（age）
  - 政見（politics）
  - 得票數（votes）
- 可以投票給候選人

`Candidate` model 一開始會有以下基本欄位（columns）:

|column|type|
|--|--|
|id|integer|
|name|string|
|party|string|
|age|integer|
|politics|text|
|votes|integers, default: 0|

### 建立 Candidate model

透過 `rails generate model <model_name> <column>` 來建立 `Candidate` model：

```shell
$ rails generate model Candidate name party age:integer politics:text votes:integer
```

- `rails generate` 可以簡寫成 `rails g`
- 如果 column type 是 `string`，可以省略不寫

`votes` column 預設值為 `0`，無法直接透過指令加入，所以打開剛剛產生的 migration，進行一個手動加入的動作：

```ruby
# ./db/migrate/XXXXX_create_candidates.rb

class CreateCandidates < ActiveRecord::Migration[5.0]
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :party
      t.integer :age
      t.text :politics
      t.integer :votes, default: 0

      t.timestamps
    end
  end
end
```

接著就可以執行 migrate，建立 tabels：

```shell
$ rails db:migrate
```

## 建立 routes

```ruby
# ./config/routes.rb

Rails.application.routes.draw do
  root 'candidates#index'
  resources :candidates
end
```

- 設定 `root`，把首頁指向 `candidates#index`
- 建立一個 `candidates` 的資源，Rails 會幫你做出 8 條路徑

使用 `rails routes` 可以查看對應的路徑：

```shell
$ rails routes
Prefix Verb   URI Pattern                    Controller#Action
          root GET    /                              candidates#index
    candidates GET    /candidates(.:format)          candidates#index
               POST   /candidates(.:format)          candidates#create
 new_candidate GET    /candidates/new(.:format)      candidates#new
edit_candidate GET    /candidates/:id/edit(.:format) candidates#edit
     candidate GET    /candidates/:id(.:format)      candidates#show
               PATCH  /candidates/:id(.:format)      candidates#update
               PUT    /candidates/:id(.:format)      candidates#update
               DELETE /candidates/:id(.:format)      candidates#destroy
```

隨著專案成長，路徑可能很大一包，如果只想查詢某部分路徑可以使用 `rails routes | grep <query_name>`，例如只想查詢跟 Products 有關的路徑：

```shell
$ rails routes | grep products#
```

也可以自行指定要想的路徑名稱，例如：

```ruby
resources :candidates, path: 'Ruby on Rails'
```

就會變成這樣：

```shell
$ rails routes
Prefix Verb   URI Pattern                      Controller#Action
          root GET    /                                candidates#index
vote_candidate POST   /9527ILoveYou/:id/vote(.:format) candidates#vote
    candidates GET    /9527ILoveYou(.:format)          candidates#index
               POST   /9527ILoveYou(.:format)          candidates#create
 new_candidate GET    /9527ILoveYou/new(.:format)      candidates#new
edit_candidate GET    /9527ILoveYou/:id/edit(.:format) candidates#edit
     candidate GET    /9527ILoveYou/:id(.:format)      candidates#show
               PATCH  /9527ILoveYou/:id(.:format)      candidates#update
               PUT    /9527ILoveYou/:id(.:format)      candidates#update
               DELETE /9527ILoveYou/:id(.:format)      candidates#destroy
```

這種方式通常會用在設計 admin 的網址，不過會使用更難猜的亂數作為路徑名稱。

## 建立 Candidates controller

接著就要進行一個 CRUD 的動作。

產生 `candidates` controller：

```ruby
$ rails g controller Candidates
```

### index action

列出所有候選人的列表：

```ruby
# ./app/controllers/candidates_controller.rb

class CandidatesController < ApplicationController
  def index
    @candidates = Candidate.all
  end
end
```

建立一個 index template：

```ruby
 # ./app/views/candidates/index.html.slim

 h1 候選人名單

table
  - @candidates.each do |candidate|
    tr
      td= candidate.name
      td= candidate.party
      td= candidate.age
      td= candidate.politics
```

### show action

呈現單一候選人的資訊：

```ruby
# ./app/controllers/candidates_controller.rb

class CandidatesController < ApplicationController
  .
  .
  def show
    @candidate = Candidate.find_by(id: params[:id])
    redirect_to candidates_path if @candidate.nil?
  end
end
```

- `redirect_to candidates_path if @candidate.nil?` 可以作為防呆機制

建立一個 show template：

```ruby
# ./app/views/candidates/show.html.slim

h1 候選人：= @candidate.name

p= @candidate.name
p= @candidate.party
p= @candidate.age
p= @candidate.politics
```

### new action

新增候選人的頁面：

```ruby
# ./app/controllers/candidates_controller.rb

class CandidatesController < ApplicationController
  .
  .
  def new
    @candidate = Candidate.new
  end
end
```

建立一個 new template：

```ruby
# ./app/views/candidates/new.html.slim

h1 新增候選人：

= simple_form_for(@candidate) do |f|
  = f.input :name, label: "Name"
  = f.input :party, label: "Party"
  = f.input :age, label: "Age"
  = f.input :politics, label: "Politics"
  = f.submit "Submit"
```

`simple_form_for` 或是內建的 `form_for` 都預期接收一個物件作為參數，然後會幫你對該物件產生一個表單，也就是：

```ruby
simple_form_for(Candidate.new)
```

不過在 view 裡面盡可能不要使用太多邏輯的程式碼，可以把 `Cabdidate.new` 存進一個 instance variable 裡面，然後在 view 裡面使用 instance variable，所以這就是為什麼上述實作程式碼會這樣寫的原因。 

### create action

建立一個候選人，`create` 透過 `POST` 把資料存進資料庫，由於這只是一個儲存的動作，所以不必有 template。

```ruby
# ./app/controllers/candidates_controller.rb

class CandidatesController < ApplicationController
  .
  .
  def create
    @candidate = Candidate.new(candidate_params)

    if @candidate.save
      redirect_to candidate_path(@candidate), notice: "Create successfully"
    else
      render :new
    end
  end

  private

  def candidate_params
    params.require(:candidate).permit(:name, :party, :age, :politics)
  end
end
```

- 使用 strong pramas 過濾參數
- 如果 `@candidate` 儲存成功，就重新導向到新建候選人的 show 頁面，並且會出現成功訊息
- 如果 `@candidate` 儲存失敗，就重新渲染 `new` view

### edit action

編輯候選人資訊：

```ruby
# ./app/controllers/candidates_controller.rb

class CandidatesController < ApplicationController
  .
  .
  def edit
    @candidate = Candidate.find_by(id: params[:id])
    redirect_to candidates_path if @candidate.nil?
end
```

建立一個 edit template：

```ruby
# ./app/views/candidates/edit.html.slim

h1 編輯候選人：

= simple_form_for(@candidate) do |f|
  = f.input :name, label: "Name"
  = f.input :party, label: "Party"
  = f.input :age, label: "Age"
  = f.input :politics, label: "Politics"
  = f.submit "Submit"
```

### update action

更新一個候選人，`update` 透過 `PUT` 把資料更新進資料庫，由於這只是一個更新的動作，所以不必有 template。

更新候選人資訊：

```ruby
# ./app/controllers/candidates_controller.rb

class CandidatesController < ApplicationController
  .
  .
  def update
    @candidate = Candidate.find_by(id: params[:id])
    redirect_to candidates_path if @candidate.nil?

    if @candidate.update(candidate_params)
      redirect_to candidate_path(@candidate), notice: "Update successful"
    else
      render :edit
    end
  end
end
```

- 使用 strong pramas 過濾參數
- 如果 `@candidate` 更新成功，就重新導向到新建候選人的 show 頁面，並且會出現成功訊息
- 如果 `@candidate` 更新失敗，就重新渲染 `edit` view

### destroy action

刪除候選人。

```ruby
# ./app/controllers/candidates_controller.rb

class CandidatesController < ApplicationController
  .
  .
  def destroy
    @candidate = Candidate.find_by(id: params[:id])
    redirect_to candidates_path if @candidate.nil?

    @candidate.destroy
    redirect_to candidates_path, notice: "Delete successfully"
  end
end
```

## 重構程式碼（Refactor）

### 重構 controller

在 `./app/controllers/candidates_controller.rb` 裡面可以看到很多重複的程式碼，可以把這些重複的東西獨立出來，讓程式碼更簡潔。

例如某些 action 會需要先找出 `@candidate` 的 `id`，某些 action 會需要傳入 strong pramas，可以把這些重複的程式碼另外寫成 method，再透過 `before_action` 調用。

需要先找出 `@candidate` 的 `id`：

```ruby
def show
  @candidate = Candidate.find_by(id: params[:id])
  redirect_to candidates_path if @candidate.nil?
end

def edit
  @candidate = Candidate.find_by(id: params[:id])
  redirect_to candidates_path if @candidate.nil?
end

def update
  @candidate = Candidate.find_by(id: params[:id])
  redirect_to candidates_path if @candidate.nil?

  if @candidate.update(candidate_params)
    redirect_to candidate_path(@candidate), notice: "Work"
  else
    render :edit
  end
end

def destroy
  @candidate = Candidate.find_by(id: params[:id])
  redirect_to candidates_path if @candidate.nil? 

  @candidate.destroy
  redirect_to candidates_path, notice: "Delete!"
end
```

`show`, `edit`, `update`, `destroy` 都需要先找到 `@candidate` 的 `id` 才能繼續做事情，所以其實可以把這段找 `id` 的程式碼另外包成一個 `find_candidate` method（寫在 `private` scope 底下）：

```ruby
private

def find_candidate
  @candidate = Candidate.find_by(id: params[:id])
  redirect_to candidates_path if @candidate.nil? # 防呆
end
```

然後就可以把這些重複到的程式碼從 actions 中拿掉，並且透過 `before_action` 調用，意思就是，在執行這些 actions 之前，先執行 `find_candidate` 這個 method（就是先幫我找到 `id` 再看你是要編輯還是更新）：

```ruby
before_action :find_candidate, only: [:show, :edit, :update, :destroy]

def show
end

def edit
end

def update
  if @candidate.update(candidate_params)
    redirect_to candidate_path(@candidate), notice: "Work"
  else
    render :edit
  end
end

def destroy
  @candidate.destroy
  redirect_to candidates_path, notice: "Delete!"
end

private

def find_candidate
  @candidate = Candidate.find_by(id: params[:id])
  redirect_to candidates_path if @candidate.nil? # 防呆
end
```

還有一個就是 strong parameters，目的是要過濾一整包的參數，有被加入白名單的參數才能被傳進去，如果不另外寫一個 method，要這樣寫也是可以的：

```ruby
def create
  @candidate = Candidate.new
  @candidate.name = params[:candidate][:name]
  @candidate.party = params[:candidate][:party]
  @candidate.age = params[:candidate][:age]
  @candidate.politics = params[:candidate][:politics]

  if @candidate.save
    redirect_to candidates_path
  else
    render :new
  end
end
```

因為這樣是很明確的指定每一個欄位要傳進的參數是哪一個。

### 重構 view

#### _form.html.slim

`new` 和 `edit` 的表單其實有 87% 像，所以可以把表單取出來存成另一個檔案，稱之為 partial，檔名前面要加底線，例如 `_form.html.slim`:

```ruby
# ./app/views/candidates/_form.html.slim

= simple_form_for(@candidate) do |f|
  = f.input :name, label: "Name"
  = f.input :party, label: "Party"
  = f.input :age, label: "Age"
  = f.input :politics, label: "Politics"
  = f.submit "Submit", class: "btn btn-primary"
```

在 `new.html.slim` 和 `edit.html.slim` 就可以把表單刪掉，加上：

```ruby
= render partial: "form" 
```

可以省略成：

```ruby
= render "form"
```

在 `_form.html.slim` 中可以使用 `@candidate` 實體變數，不過這有點像是讓 `_form.html.slim` 嘗試去抓空氣中的實體變數，實務上比較好的做法是不要讓 partial 去主動預期它可能會抓到「某個實體變數」，而是讓 partail 被動的等待你給他「某個實體變數」的資訊。再者，這樣也可以讓 partial 比較容易被重複使用，不會被侷限在 `@candidate` 變數上。

所以在 `render` 部分可以改成：

```ruby
= render partial: "form", local: { candidate: @candidate }
```

可以省略成：

```ruby
= render "form", candidate: @candidate
```

然後就可以把 `_form.html.slim` 的 `@candidate` 變數改成你指定的 `candidate`：

```ruby
= simple_form_for(candidate) do |f|
  .
  .
```

雷區，如果寫成這樣會錯誤，因為你要嘛就全部省略，要嘛就是不要省略（請看上面的寫法）：

```ruby
= render partial: "form", candidate: @candidate # error
```

#### _candidate.html.slim

在 `views/candidates/index.html.slim` 的 `simple_form_for` 也可以取出來：

```ruby
# views/candidates/index.html.slim

h1 Candidate lists

= render "candidate"
```

```ruby
# views/candidates/_candidate.html.slim

- @candidates.each do |candidate|
  h4.card-title= candidate.name
  p.card-text= candidate.party
  p.card-text= candidate.age
  = link_to 'Detail', candidate_path(candidate)
  = link_to 'Edit', edit_candidate_path(candidate)
  = link_to 'Delete', candidate_path(candidate), method: :delete, data: { confirm: "Sure?"}
```

其中，三個 `link_to` 的連結路徑都可以再簡化成：

```ruby
= link_to 'Detail', candidate
= link_to 'Edit', candidate
= link_to 'Delete', candidate, method: :delete
```

因為它需要的只是一個 `id`。

## 投票功能

現在要加上投票功能。

### 增加 vote routes

預計要做一個 `/candidates/:id/vote` 的路徑，也就是會找出某個候選人 `id` 然後進行一個投票的動作。

```ruby
# config/routes.rb

resources :candidates do
  member do 
    post :vote
  end
end
```

也可以寫成：

```ruby
resources :candidates do
  post :vote, on: :member
end
```

#### routes

可以這樣做出路徑：

```ruby
get "/candidates", to: "candidates#index"
get "/candidates/:id", to: "candidates#show"
post "/candidate/:id/vote", to: "candidate#vote"
```

但如果需要更有系統的整理，通常就會利用 `resoureces`、`member`、`collection` 來整理相關的路徑。

### 在 view 加上 vote link 和 vote count

```ruby
# views/candidates/_candidate.html.slim

- @candidates.each do |candidate|
  h4.card-title= candidate.name
  p.card-text= candidate.party
  p.card-text= candidate.age
  p.card-text= candidate.votes
  = link_to 'Vote', vote_candidate_path(candidate), method: :post, data: { confirm: "Sure?" }
  = link_to 'Detail', candidate_path(candidate)
  = link_to 'Edit', edit_candidate_path(candidate)
  = link_to 'Delete', candidate_path(candidate), method: :delete, data: { confirm: "Sure?"}
```

### 在 controller 加上 vote action

```ruby
# controllers/candidates_controller.rb

def vote
  @candidate.votes = @candidate.votes + 1
  @candidate.save
  redirect_to candidates_path
end
```

其中也可以使用 `.increment` method：

```ruby
def vote
  @candidate.increment(:votes)
  @candidate.save
  redirect_to candidates_path
end
```

### 建立 VoteLog model 記錄投票資訊

原本在 `candidates` table 建立了一個 `votes` column，不過如果想知道誰投票給候選人以及投票時間或是 IP，就無法得知。

所以現在要多建立一個 `vote_logs` table，來關聯到 `candidates`，記錄投票資訊：

|column|type|
|--|--|
|id|integer|
|ip_address|string|
|candidate_id|integer| 

也就是會記錄：

- 投票時間
- 投票給誰
- 投票時的 IP

產生一個 `VoteLog` model：

```shell
$ rails g model VoteLog ip_address candidate_id:integer
```
也可以這樣寫：

```shell
$ rails g model VoteLog ip_address candidate:references
```

`candidate:references` 除了會加上 foreign key (`candidate_id`)，還會加上 index。

執行 `rails db:migrate`

在 `Candidate` model 加上關聯：

```ruby
class Candidate < ApplicationRecord
  has_many :vote_logs
end
```

在 `VoteLog` model 加上關聯：

```ruby
class VoteLog < ApplicationRecord
  belongs_to :candidate
end
```

加上關聯後，會產生一些可以使用的 method，例如：

```ruby
Candidate.first.vote_logs # 查詢第一個候選人的得票記錄
VoteLog.last.candidate # 查詢最後一張票投給該候選人的記錄
```

調整 `Candidates` controller 的 `vote` action：

```ruby
class CandidatesController < ApplicationController
  .
  .
  def vote
    log = VoteLog.new(ip_address: request.remote_ip, candidate: @candidate)
    log.save

    redirect_to candidates_path
  end
end
```

但其實也可以從候選人的角度去建立投票，比較直覺一點：

```ruby
class CandidatesController < ApplicationController
  .
  .
  def vote
    @candidate.vote_logs.create(ip_address: request.remote_ip)

    redirect_to candidates_path
  end
end
```

接著調整 `_candidate.html.slim` 的 vote count ：

```ruby
# views/candidates/_candidate.html.slim

# 原本
candidate.votes

# 改成
candidate.vote_logs.count
```

### Counter Cache

目前如果有 3 筆資料，但查看 log 會發現資料庫做了 4 次查詢，這是所謂的 N + 1 query 問題。簡單來說就是會耗效能。

可以使用 Counter Cache 的做法解決：

- 把投票結果「更新」到 `Candidate` model
- 投票記錄會放在 `VoteLog` model

為了要在 `Candidate` model 記錄「投票結果」，就要再開一個 `vote_logs_count:integer` column：

```shell
$ rails g migration add_counter_to_candidates vote_logs_count:integer
```

產生一個 migration，然後加上預設值為 0：

```ruby
class AddCounterToCandidates < ActiveRecord::Migration[5.0]
  def change
    add_column :candidates, :vote_logs_count, :integer, default: 0
  end
end
```

執行 `rails db:migrate`

接著調整 `VoteLog` model：

```ruby
class VoteLog < ApplicationRecord
  belongs_to :candidate, counter_cache: true
end
```

再調整 `_candidate.html.slim`：

```ruby
# views/candidates/_candidate.html.slim

# 原本
candidate.vote_logs.count

# 改成，因為原本的 count 還是會做 N + 1 query
candidate.vote_logs.size
```

### 建立 lib/tasks/reset_counter.rake 清除投票紀錄

```ruby
namespace :vote do
  desc "Reset Counter Cache"
  task :reset_counter => :environment do
    Candidate.all.each do |candidate|
      Candidate.reset_counters(candidate.id, :vote_logs)
    end
  end
end
```

執行起來會是：

```shell
$ rails vote:reset_counter
```

## 安裝一些好用的 Gems

```ruby
# Gemfile

.
.
gem "slim-rails"
gem 'bootstrap', '~> 4.0.0.alpha6'
gem 'font-awesome-sass'
gem "simple_form"

group :development, :test do
  .
  .
  gem 'pry-rails'
end
```

- 使用 Slim 取代 ERb，因為可以少打更多字，而且註解太方便
- 使用 bootstrap 4 快速建立前端 template
- 由於 bootstrap 4 之後就不再提供 font icon，所以使用 FontAwesome 來代替
- 使用 simple form 來取代 Rails 原生的囉唆語法，而且可以搭配 bootstrap 使用
- 使用 pry 讓 console 介面容易閱讀，而且也是 debug 利器

更新完 `Gemfile`，就可以執行 `bundle`，把 gems 安裝起來。

## slim-rails

- Gem: https://rubygems.org/gems/slim-rails/versions/3.1.1?locale=zh-TW
- GitHub: https://github.com/slim-template/slim-rails
- Slim Doc: http://slim-lang.com/

## bootstrap

**bootstrap 3**

- GitHub: https://github.com/twbs/bootstrap-sass

**bootstrap 4**

- GitHub: https://github.com/twbs/bootstrap-rubygem

Gemfile

```ruby
gem 'bootstrap', '~> 4.0.0.alpha6'
```

app/assets/stylesheets/application.scss

```scss
@import "bootstrap";
```

app/assets/javascripts/application.js

```javascript
//= require jquery
//= require bootstrap-sprockets
```

## font-awesome-sass

- GitHub: https://github.com/FortAwesome/font-awesome-sass

Gemfile

```ruby
gem 'font-awesome-sass', '~> 4.7.0'
```

app/assets/stylesheets/application.css.scss

```scss
@import "font-awesome-sprockets";
@import "font-awesome";
```

Rails Helper

```ruby
icon('flag')
# => <i class="fa fa-flag"></i>
```

```ruby
icon('flag', class: 'strong')
# => <i class="fa fa-flag strong"></i>
```

```ruby
icon('flag', 'Font Awesome', id: 'my-icon', class: 'strong')
# => <i id="my-icon" class="fa fa-flag strong"></i> Font Awesome
```

### simple_form

- GitHub: https://github.com/plataformatec/simple_form

Gemfile

```ruby
gem 'simple_form'
```

Run the generator

```shell
$ rails generate simple_form:install
```

Run the generator with bootstrap

```shell
rails generate simple_form:install --bootstrap
```

### pry

- GitHub: https://github.com/rweng/pry-rails

