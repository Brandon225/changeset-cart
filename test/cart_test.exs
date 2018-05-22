defmodule CartTest do
  use ExUnit.Case
  doctest Cart

  alias Cart.{Repo, Customer}

  test "greets the world" do
    assert Cart.hello() == :world
  end

  test "create a new customer" do
    carrie_changeset =
      %Cart.Customer{}
      |> Customer.changeset(%{first_name: "May", last_name: "Sandy", email: "sandymay@yahoo.com", birthday: "10/25/1982"})
    assert {:ok, _} = Repo.insert carrie_changeset
  end
end
