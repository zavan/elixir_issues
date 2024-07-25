defmodule Issues.GithubIssues do
  require Logger

  @headers [ { "User-Agent", "Elixir felipe@zavan.me" } ]

  def fetch(user, project) do
    Logger.info "Fetching issues for #{user}/#{project}"
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
    Logger.info "Successfully fetched issues"
    Logger.debug fn -> inspect(body) end
    { :ok, Poison.Parser.parse!(body) }
  end

  def handle_response({ _, %{status_code: _, body: body} }) do
    Logger.error "Failed to fetch issues"
    { :error, Poison.Parser.parse!(body) }
  end
end
