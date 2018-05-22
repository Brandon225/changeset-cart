defmodule Cart.Repo.Migrations.CreateCustomer do
  use Ecto.Migration

  def change do
    create table(:customer, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :first_name, :text
      add :last_name, :text
      add :email, :text
      add :birthday, :text
    end
  end
end
