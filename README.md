# Changeset Validations - A journey through changeset validations

### Table of Contents

- [Regex Validation](#regex)
- [Email Validation](#email)
- [Embedded Changesets](#embed)



## Regex Validation<a name="regex"></a>
>**Example**

```
  def changeset(data, params \\ %{}) do
    data
    |> cast(params, @fields)
    |> validate_required([:birthday])
    |> validate_date(:birthday)
  end 

  def validate_date(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, birthday ->
      case birthday =~ ~r/(\d{2})\/(\d{2})\/(\d{4})/ do
        true -> []
        false -> [{field, options[:message] || "Invalid Format.  Please use mm/dd/yyyy."}]
      end
    end)
  end
```

## Email Validation<a name="email"></a>

>**Example**

```
  def changeset(data, params \\ %{}) do
    data
    |> cast(params, @fields)
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
```

## Embedded Changesets<a name="embed"></a>

>**Example**
```
defmodule Cart.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query

  alias Cart.{Customer, Repo}

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
    |> validate_required([:first_name, :last_name, :email, :birthday])
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
```

>**Passing Test in iex**

```
iex(1)> billingAddress = %{addr1: "1313 Mocking Bird Lane", addr2: "#101", city: "Los Angeles", state: "CA", zipCode: "90210"}
%{
  addr1: "1313 Mocking Bird Lane",
  addr2: "#101",
  city: "Los Angeles",
  state: "CA",
  zipCode: "90210"
}

iex(2)> customer = Cart.Customer.changeset(%Cart.Customer{}, %{first_name: "Seth", last_name: "Smith", email: "Seth.Smith@gmail.com", birthday: "02/26/1981", billingAddress: billingAddress})
#Ecto.Changeset<
  action: nil,
  changes: %{
    billingAddress: #Ecto.Changeset<
      action: :insert,
      changes: %{
        addr1: "1313 Mocking Bird Lane",
        addr2: "#101",
        city: "Los Angeles",
        state: "CA",
        zipCode: "90210"
      },
      errors: [],
      data: #Cart.Customer.BillingAddressSchema<>,
      valid?: true
    >,
    birthday: "02/26/1981",
    email: "Seth@me.com",
    first_name: "Seth",
    last_name: "Smith"
  },
  errors: [],
  data: #Cart.Customer<>,
  valid?: true
>
```

>**Failing Test in iex**

```
iex(1)> billingAddress = %{addr1: "1313 Mocking Bird Lane", addr2: "#101", city: "Los Angeles", state: "California", zipCode: "90210"}
%{
  addr1: "1313 Mocking Bird Lane",
  addr2: "#101",
  city: "Los Angeles",
  state: "CA",
  zipCode: "90210"
}

iex(2)> customer = Cart.Customer.changeset(%Cart.Customer{}, %{first_name: "Seth", last_name: "Smith", email: "Seth.Smith@gmail.com", birthday: "02/26/81", billingAddress: billingAddress})
#Ecto.Changeset<
  action: nil,
  changes: %{
    billingAddress: #Ecto.Changeset<
      action: :insert,
      changes: %{
        addr1: "1313 Mocking Bird Lane",
        addr2: "#101",
        city: "Los Angeles",
        state: "CA",
        zipCode: "90210"
      },
      errors: [],
      data: #Cart.Customer.BillingAddressSchema<>,
      valid?: true
    >,
    birthday: "02/26/1981",
    email: "Seth.Smith@me.com",
    first_name: "Seth",
    last_name: "Smith"
  },
  errors: [],
  data: #Cart.Customer<>,
  valid?: true
>
```


