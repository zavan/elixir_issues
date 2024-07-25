defmodule Issues.GithubIssues do
  @headers [ { "User-Agent", "Elixir felipe@zavan.me" } ]

  def fetch(user, project) do
    issues_url(user, project)
      |> HTTPoison.get(@headers)
      |> handle_response
  end

  # "In any case, compile-time environments should be avoided. Whenever possible, reading the application environment at runtime should be the first choice."
  # https://hexdocs.pm/elixir/1.17.2/Application.html#module-compile-time-environment
  def github_url, do: Application.fetch_env!(:issues, :github_url)

  def issues_url(user, project) do
    "#{github_url()}/repos/#{user}/#{project}/issues"
  end

  def handle_response({ :ok, %{ status_code: 200, body: body } }) do
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({ _, %{status_code: _, body: body} }) do
    { :error, Poison.Parser.parse!(body) }
  end
end
