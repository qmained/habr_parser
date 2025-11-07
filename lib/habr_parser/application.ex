defmodule HabrParser.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task, fn -> Crawly.Engine.start_spider(MyParser) end}
    ]

    opts = [strategy: :one_for_one, name: HabrParser.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
