# Elixir Plug 앱 만들기

mix는 elixir와 함께 설치되는 프로그램 입니다. Node.js 생태계의 npm과 같은 위치입니다.

**mix로 프로젝트 생성**

```bash
$ mix new learn_plug
```

mix 프로젝트를 만들때 프로젝트 이름은 소문자와 숫자, 밑줄(underscore)만 사용할 수 있습니다.

**의존성 설치**

elixir 프로젝트에서 사용할 의존성을 설치하려면 `mix.exs`파일을 열어 다음과 같이 추가합니다.

```elixir
# mix.exs
defp deps do
  [{:plug, "~> 1.3"},
   {:cowboy, "~> 1.0"}]
end
```

```bash
$ mix deps.get
```

elixir 프로젝트에서 사용할 수 있는 의존성 목록은 [hex.pm](https://hex.pm/packages)에서 확인하실 수 있습니다.


**웹 앱 만들기**

`lib/learn_plug.ex`파일을 열어 다음과 같이 수정합니다. Plug.Conn을 이용해 외부에서 들어오는 연결을 처리할 것 입니다.

```elixir
defmodule LearnPlug do
  import Plug.Conn

  def init(opts) do
    Map.put(opts, :my_option, "Hello")
  end

  def call(conn, opts) do
    send_resp(conn, 200, "#{opts[:my_option]}, World!")
  end
end
```

**앱 실행**

mix 앱은 두가지 방법으로 실행할 수 있습니다.

```
mix
```

```
iex -S mix
```

**iex -S**를 통해 앱을 실행하면 상호작용할 수 있는 터미널 앱을 함께 사용할 수 있습니다.
**iex** 방식을 이용하여 실행합니다.

앱만 실행하면 사용자 요청을 처리할 수 없습니다. 요청을 처리하는 **Cowboy**를 실행합니다.

```
iex(1)> Plug.Adapters.Cowboy.http(LearnPlug, %{})
```

이제 브라우저를 열어 `http://localhost:4000` 주소로 접속하면 Hello World! 문구를 볼 수 있습니다.


<!-- TODO: Cowboy 설정에 관한 내용이 필요함. -->

**Hello 라우트**

지금까지 작업한 내용은 `http://localhost:4000` 이 아닌 주소로 접속하면 모두 **Oops!**를 보여줍니다.

이번에는  `http://localhost:4000/hello`로 접속할 수 있도록 변경합니다.

```elixir
# router.ex
get "/hello" do
  send_resp(conn, 200, "Hello Elixir!")
end
```

새 라우트 `/hello`를 추가했습니다. 위 주소로 들어가면 Hello Elixir를 보여줍니다.

**파라미터를 가지는 라우트**

hello 라우트는 항상 `Hello Elixir`만 보여줍니다. `/hello/:name` 라우트를 만들어 주소에 이름을 넣으면 `Hello :name`이 나오도록 만듭니다.

```elixir
get "/hello/:name" do
  send_resp(conn, 200, "Hello #{name}!")
end
```

`:name`은 파라미터입니다. `do ~ end` 블럭에서 사용할 수 있습니다.

**라우트 모듈화**

`router.ex`파일에 **hello** 관련 라우트는  `/hello` 와 `/hello/:name` 라우트로 두개입니다. 점점 복잡해지는 경우 `router.ex`파일은 계속 거대해 질 것입니다. 이를 막기 위해 `/hello` 관련 라우트를 모듈로 분리할 필요가 있습니다.

`lib` 디렉터리 아래 다음과 같이 파일/디렉터리를 만듭니다.

```
`lib
| - routes
` - - hello_routes.ex
```

`hello_routes.ex`파일의 내용입니다.

```elixir
#hello_routes.ex
defmodule LearnPlug.HelloRoutes do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello Elixir!")
  end

  get "/:name" do
    send_resp(conn, 200, "Hello #{name}!")
  end
end
```

이제 기존에 있는 라우트를 `router.ex`에서 지웁니다.

```elixir
#router.ex
defmodule LearnPlug.Router do
  use Plug.Router
  alias LearnPlug.HelloRoutes

  plug :match
  plug :dispatch


  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  forward "/hello", to: HelloRoutes

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
```

지금까지 작성한 시나리오 모두 동일하게 작동합니다.


**새로운 API 생성**

endpoint는 **/books** 입니다. 사용자가 http://localhost:4000 에 요청하면 책과 관련된 내용을 반환합니다. 우선 라우트를 만듭니다.

```elixir
# router.ex
...
forward "/hello", to: LearnPlug.HelloRoutes
forward "/books", to: LearnPlug.BookRoutes
...
```

위 예제에서는 alias를 이용했지만 이번에는 모듈 이름을 그대로 적었습니다.

```elixir
#routes/book_routes.ex
defmodule LearnPlug.BookRoutes do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Book")
  end
end
```

`http://localhost:4000/books` 로 접속하면 Book 이라는 문자를 볼 수 있습니다.


elixir는 파이프를 제공하여 이전 요청의 결과를 다음 함수로 전달할 수 있습니다. 위에서 만든 `get "/" do ~ end` 부분을 아래와 같이 변경합니다.

```elixir
get "/" do
  conn
  |> send_resp(200, "Book")
end
```
send_resp의 첫번째 파라미터였던 conn을 분리했습니다.

새로운 엔드포인트인 "/books/:id"를 만들어 봅니다. 아직 데이터베이스를 사용하지 않기 때문에 임의로 만듭니다.

```elixir
get "/:id" do
  conn
  |> send_resp(200, "Book")
end
```

**JSON 응답**

Plug 앱을 JSON 서버로 사용할 수도 있습니다. 사용자의 요청을 받으면 해당하는 결과를 JSON 형식으로 반환해봅니다. JSON을 이용하기 위해 **poison**모듈을 추가합니다.

```elixir
#mix.exs
defp deps do
  [
    {:plug, "~> 1.3"},
    {:cowboy, "~> 1.0"},
    {:poison, "~> 3.0"}
  ]
end
```

Poison을 사용하려면 `application`에 추가해야합니다.
```elixir
def application do
  [
    extra_applications: [:logger, :cowboy, :plug, :poison],
    mod: { LearnPlug, [] }
  ]
end
```

`:poison`을 추가하여 이제 Poison 모듈을 사용할 수 있습니다.

Poison을 사용해 위에서 만든 `/:id` 응답의 내용을 다음과 같이 변경합니다.

```elixir
#book_routes.ex
get "/:id" do
  conn
  |> put_resp_content_type("application/json")
  |> send_resp(200, Poison.encode!(%{
    :name => "The Interpretation of Dreams",
    :author => "Sigmund Freud",
    :publishedAt => "1900"
  }))
end
```

**Ecto 설치**

Ecto는 Elixir 환경에서 데이터베이스에 접속하고, 조작할 수 있도록 만들어진 모듈입니다. 여기서는 **postgresql** 데이터베이스를 이용합니다.

Ecto와 Postgresql을 사용하려면 `postgrex` 모듈도 함께 필요합니다. 두가지 모듈을 앱 의존성에 추가합니다.

```elixir
defp deps do
  [
    {:plug, "~> 1.3"},
    {:cowboy, "~> 1.0"},
    {:poison, "~> 3.0"},
    {:ecto, "~> 2.1.4"},
    {:postgrex, ">= 0.13.2"}
  ]
end
```

그리고 앱에서 사용하도록 지정합니다.

```elixir
def application do
  # Specify extra applications you'll use from Erlang/Elixir
  [
    extra_applications: [:logger, :cowboy, :plug, :poison, :ecto, :postgrex],
    mod: { LearnPlug, [] }
  ]
end
```

터미널에서 다음 명령어를 실행하여 의존성 설치를 합니다.

```elixir
$ mix deps.get
```

Ecto는 데이터베이스를 감싸는 저장소(Repo)를 사용합니다. 이를 위해 `mix ecto.gen.repo` 명령어를 실행합니다.

아무런 설정을 하지 않으면 경고 메시지가 출력됩니다. `config/config.exs` 파일을 열어 설정 내용을 적어줍니다.

```elixir
# config.exs
config :learn_plug, :ecto_repos, [LearnPlug.Repo]
```

다시 터미널에서 실행하면 `config.exs` 파일에 설정이 추가됩니다. Postgresql 설정을 변경하지 않았다면 아래와 같이 수정합니다.


```elixir
config :learn_plug, LearnPlug.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "learn_plug_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
```

그리고 `lib/learn_plug` 디렉터리에 repo.ex 파일이 만들어진 것을 확인할 수 있습니다.

Ecto를 사용하기 위해서 `learn_plug.ex` 파일에 **Supervisor** 설정을 해야합니다. `def start` 메소드를 수정합니다.

```elixir
def start(_type, _args) do
  import Supervisor.Spec

  children = [
    Plug.Adapters.Cowboy.child_spec(:http, LearnPlug.Router, [], port: 4000),
    supervisor(LearnPlug.Repo, [])
  ]

  Logger.info "Started application http://localhost:4000"

  opts = [strategy: :one_for_one, name: LearnPlug.Supervisor]
  Supervisor.start_link(children, opts)
end
```

**Ecto + Mix 태스크 목록**

```elixir
mix ecto.create         # 저장소에 공간을 생성합니다
mix ecto.drop           # 저장소의 공간을 삭제합니다
mix ecto.gen.migration  # 저장소의 새로운 마이그레이션을 생성합니다
mix ecto.gen.repo       # 새로운 저장소를 생성합니다
mix ecto.migrate        # 저장소의 마이그레이션을 실행합니다
mix ecto.rollback       # 저장소의 마이그레이션을 롤백합니다
```

데이터베이스를 만들기위해 `mix ecto.create`를 실행합니다. 정상적으로 설정이 되어 있으면 저장소가 만들어졌다는 메시지가 출력됩니다.

**첫번째 마이그레이션**

mix 태스크를 이용해 첫번째 태스크를 만듭니다. 마이그레이션 이름은 `books` 입니다. 터미널에서 다음과 같이 입력합니다.

```terminal
$ mix ecto.gen.migration add_books_table
```

`priv` 디렉터리에 `repo/migrations` 디렉터리와 마이그레이션 파일이 만들어졌습니다. **books**테이블 마이그레이션 설정을 합니다.

```
defmodule LearnPlug.Repo.Migrations.AddBooksTable do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :author, :string
      add :language, :string
      add :isbn, :string

      timestamps()
    end
  end
end
```

터미널에서 위 마이그레이션을 데이터베이스에 반영하기 위해 mix 태스크를 이용합니다.

```elixir
$ mix ecto.migrate
```

성공하면 `create table books` 등의 명령어가 나옵니다.

**첫번째 스키마**

Ecto는 Book 테이블에서 사용할 스키마가 필요합니다.

```elixir
defmodule LearnPlug.Book do
  use Ecto.Schema

  schema "books" do
    field :name, :string
    field :author, :string
    field :language, :string
    field :isbn, :string

    timestamps()
  end
end
```

테이블에 정의했던 내용과 동일한 필드를 가지도록 만들었습니다. 터미널에서 첫번째 데이터를 추가합니다.

```bash
$ iex -S mix # 앱 실행
```

```elixir
iex(1)> alias LearnPlug.Repo # Repo 알리아스 선언
iex(2)> alias LearnPlug.Book # Book 알리아스 선언
iex(3)> book = %Book{ author: "Siegmund Freud", language: "German", name: "Die Traumdeutung", isbn: "1234"} # Book 데이터 정의
iex(4)> { :ok, book } = Repo.insert book # Repo에 삽입
iex(5)> Repo.all(Book)
```
위 순서대로 실행하면 저장소에 첫번째 책을 추가합니다.

**JSON으로 반환하기**

BookRoutes의 `get "/"`로 접속하면 전체 책 내용을 반환하도록 만들어봅니다.
JSON 형식으로 데이터를 반환하려면 우선 스키마 모델이 Poison 인코더를 사용한다고 지정해야합니다. `/models/book.ex` 파일을 수정합니다.

```elixir
defmodule LearnPlug.Book do
  use Ecto.Schema

  @derive { Poison.Encoder, except: [:__meta__] }
  schema "books" do
    field :name, :string
    field :author, :string
    field :language, :string
    field :isbn, :string

    timestamps()
  end
end
```

그리고 `book_routes.ex`의 `get "/"`를 수정합니다. `get "/:id"`와 유사합니다.

```elixir
get "/" do
  books = Repo.all(Book)
  conn
  |> put_resp_content_type("application/json")
  |> send_resp(200, Poison.encode!(books))
end
```

`get "/:id"` 라우트도 변경합니다.

```elixir
get "/:id" do
  book = Repo.get(Book, id)
  conn
  |> put_resp_content_type("application/json")
  |> send_resp(200, Poison.encode!(book))
end
```

`localhost:4000/books/1` 로 접속하면 위에서 추가한 Book 객체를 받을 수 있습니다.
