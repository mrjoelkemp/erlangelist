defmodule Erlangelist.Core.Article do
  use Boundary, deps: [Erlangelist.Core.UsageStats]
  @external_resource "articles/index.exs"

  months = ~w(January February March April May June July August September October November December)
  days_abbr = ~w(Mon Tue Wed Thu Fri Sat Sun)
  months_abbr = Enum.map(months, &String.slice(&1, 0..2))

  to_rfc822 = fn date ->
    dow = Enum.at(days_abbr, Date.day_of_week(date) - 1)
    mon = Enum.at(months_abbr, date.month - 1)
    year = rem(date.year, 100)
    "#{dow}, #{date.day} #{mon} #{year} 00:00:00 +0000"
  end

  date_to_string = fn date -> "#{Enum.at(months, date.month - 1)} #{date.day}, #{date.year}" end

  article_meta = fn {article_id, article_spec} ->
    date = Date.from_iso8601!(article_spec[:posted_at])

    Enum.into(article_spec, %{
      id: article_id,
      posted_at: date_to_string.(date),
      copyright_year: date.year,
      posted_at_rfc822: to_rfc822.(date),
      title: Keyword.fetch!(article_spec, :title),
      sidebar_title: Keyword.get_lazy(article_spec, :sidebar_title, fn -> Keyword.fetch!(article_spec, :title) end),
      link: "/article/#{article_id}",
      source_link: "https://github.com/sasa1977/erlangelist/tree/master/site/articles/#{article_id}.md",
      content: File.read!("articles/#{article_id}.md")
    })
  end

  {articles_specs, _} = Code.eval_file("articles/index.exs")
  articles_meta = Enum.map(articles_specs, article_meta)

  def all, do: unquote(Macro.escape(articles_meta))

  def read(:most_recent) do
    {:ok, article} = read(unquote(to_string(hd(articles_meta).id)))
    {:ok, article}
  end

  for article <- articles_meta do
    @external_resource "articles/#{article.id}.md"
    def read(unquote(to_string(article.id))) do
      article = unquote(Macro.escape(article))
      Erlangelist.Core.UsageStats.report(:article, article.id)
      {:ok, article}
    end
  end

  def read(_), do: :error
end
