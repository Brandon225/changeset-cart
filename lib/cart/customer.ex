defmodule Cart.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query

  alias Cart.{Customer, Repo}

  # TODO: Add too_many relationship with Invoices

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "customers" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :birthday, :string
    embeds_one(:billingAddress, Customer.BillingAddress)
  end

  @fields ~w(first_name last_name email birthday)

  def changeset(data, params \\ %{}) do
    data
    |> cast(params, @fields) # create with fields defined above
    |> cast_embed(:billingAddress)
    # |> validate_required([:first_name, :last_name, :email, :birthday])
    |> validate_length(:first_name, max: 10)
    |> validate_length(:last_name, max: 10)
    |> validate_format(:email, ~r/@/)
    |> validate_date(:birthday)
    |> unique_constraint(:email)
  end

  def validate_date(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, birthday ->
      case birthday =~ ~r/(\d{2})\/(\d{2})\/(\d{4})/ do
        true -> []
        false -> [{field, options[:message] || "Invalid Format.  Please use mm/dd/yyyy."}]
      end
    end)
  end

  def create(params) do
    cs = changeset(%Customer{}, params)

    if cs.valid? do
      Repo.insert(cs)
    else
      cs
    end
  end

  defmodule BillingAddress do
    use Ecto.Schema

    @primary_key false
    schema "" do
        field :addr1, :string
        field :addr2, :string
        field :city, :string
        field :state, :string
        field :zipCode, :string
    end

    @fields ~w(addr1 addr2 city state zipCode)

    def changeset(billing = %BillingAddress{}, attrs) do
      billing
      |> cast(attrs, @fields)
      |> validate_required([:state])
      |> validate_length(:state, max: 2)
    end

  end
end
