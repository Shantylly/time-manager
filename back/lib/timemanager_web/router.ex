defmodule TodolistWeb.Router do
  use TodolistWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TodolistWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TodolistWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", TodolistWeb do
    pipe_through [:api]
    resources "/users", UserController, except: [:new, :edit]
    resources "/teams", TeamController, except: [:new, :edit]
    resources "/timespents", TimespentController, except: [:new, :edit, :show]

    get "/users/team/:team_id", UserController, :index_by_team
    get "/timespents/:user_id", TimespentController, :list_timespents_by_user
    get "/users_by_team", TeamController, :list_users_by_team

    post "/clock_in/:user_id", ClockController, :clock_in
    post "/clock_out/:user_id", ClockController, :clock_out
    post "/login", UserController, :sign_in
    get "/teamsUsers", TeamController, :list_users_for_each_team
    get "/clock_status/:user_id", ClockController, :is_clocked_in
  end

  scope "/metrics" do
    forward "/", PromEx.Plug, metrics: :all
  end

end
