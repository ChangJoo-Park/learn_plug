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
