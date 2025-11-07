defmodule MyParser do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://habr.com/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: gen_urls(base_url(), 1..50//5)
    ]
  end

  defp gen_urls(base_url, range) do
    range
    |> Enum.map(fn i ->
      Crawly.Utils.build_absolute_url("/ru/articles/page#{i}/", base_url)
    end)
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    items =
      document
      |> Floki.find("article")
      |> Stream.map(fn x ->
        %{
          title: Floki.find(x, ".tm-title__link") |> Floki.text(),
          url:
            Floki.find(x, ".tm-title__link")
            |> Floki.attribute("href")
            |> Enum.map(fn url -> Crawly.Utils.build_absolute_url(url, response.request.url) end)
            |> List.first(),
          votes: Floki.find(x, ".tm-votes-meter__value") |> Floki.text(),
          comments:
            Floki.find(x, ".article-comments-counter-link")
            |> Floki.find("span")
            |> Floki.text(),
          time:
            Floki.find(x, ".tm-article-datetime-published")
            |> Floki.find("time")
            |> Floki.attribute("datetime")
            |> List.first()
        }
      end)
      |> Enum.filter(fn %{votes: votes, comments: comments} ->
        Integer.parse(votes)
        |> then(fn
          {int, _} -> int
          _ -> IO.puts("Error: #{votes}")
        end) < 0 and
          comments
          |> Integer.parse()
          |> elem(0) > 10
      end)

    urls =
      document
      |> Floki.find("#pagination-next-page")
      |> Floki.attribute("href")
      |> Enum.map(fn url ->
        Crawly.Utils.build_absolute_url(url, response.request.url)
        |> Crawly.Utils.request_from_url()
      end)

    %Crawly.ParsedItem{items: items, requests: urls}
  end
end
