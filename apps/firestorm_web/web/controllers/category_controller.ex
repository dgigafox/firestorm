defmodule FirestormWeb.CategoryController do
  use FirestormWeb.Web, :controller
  alias FirestormData.Commands.GetCategory

  def show(conn, %{"id" => id_or_slug}) do
    finder =
      case Integer.parse(id_or_slug) do
        :error ->
          id_or_slug
        {id, _} -> id
      end

    case GetCategory.run(%GetCategory{finder: finder}) do
      {:ok, c} ->
        conn
        |> render("show.html", category: c)
      {:error, :not_found} ->
        conn
        |> put_flash(:error, "No such category!")
        |> redirect(to: page_path(conn, :home))
    end
  end

  def new(conn, params) do
    changeset =
      %Category{}
      |> Category.changeset(params)

    conn
    |> render("new.html", changeset: changeset)
  end

  # FIXME: Use commands, don't just CRUD it up
  def create(conn, %{"category" => category_params}) do
    changeset =
      %Category{}
      |> Category.changeset(category_params)

    case changeset.valid? do
      true ->
        case Repo.insert(changeset) do
          {:ok, category_id} ->
            conn
            |> put_flash(:info, "Category created successfully")
            |> redirect(to: category_path(conn, :show, category_id))
          {:error, changeset} ->
            conn
            |> render("new.html", changeset: changeset)
        end
      false ->
        conn
        |> render("new.html", changeset: changeset)
    end
  end
end
