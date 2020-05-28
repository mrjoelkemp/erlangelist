defmodule ErlangelistWeb.BlogTest do
  use ExUnit.Case, async: true
  import Phoenix.ConnTest
  alias Erlangelist.Article
  alias ErlangelistTest.Client

  test "root page shows the most recent article" do
    assert response(Client.get("/"), 200) =~ "<h1>#{Plug.HTML.html_escape(Article.most_recent().title)}</h1>"
  end

  for article <- Article.all(), article.has_content? do
    test "shows the #{article.id} article" do
      assert response(Client.article(unquote(article.id)), 200) =~
               "<h1>#{Plug.HTML.html_escape(unquote(article.title))}</h1>"
    end
  end

  test "renders not found for unknown article" do
    assert response(Client.article("unknown_article"), 404) =~ "Page not found"
  end

  test "serves rss feed" do
    response = response(Client.rss_feed(), 200)

    for article <- Article.all(), article.has_content? do
      assert response =~ "<h1>#{Plug.HTML.html_escape(article.title)}</h1>"
    end
  end

  test "http requests are redirected to https" do
    assert redirected_to(Client.get("http://localhost/"), 301) == "https://localhost/"
  end

  test "theerlangelist.com is redirected to www.theerlangelist.com" do
    assert redirected_to(Client.get("https://theerlangelist.com/"), 301) == "https://www.theerlangelist.com/"
  end
end

defmodule ErlangelistWeb.Blog.CertificationTest do
  use ExUnit.Case, async: false
  import SiteEncrypt.Phoenix.Test

  test "certification" do
    clean_restart(ErlangelistWeb.Blog.Endpoint)
    cert = get_cert(ErlangelistWeb.Blog.Endpoint)
    assert cert.domains == ~w/theerlangelist.com www.theerlangelist.com/
  end
end
