# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Todolist.Repo.insert!(%Todolist.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# priv/repo/seeds.exs

Todolist.Users.create_user(%{
  firstname: "John",
  lastname: "Doe",
  address: "123 Street, City",
  role: "User",
  mail: "john@example.com",
  phone: "0607080911",
  team_id: 2,
  password: "password123",
  genre: "H"
})
Todolist.Users.create_user(%{
  firstname: "Fiona",
  lastname: "Filo",
  address: "432 Street, City",
  role: "User",
  mail: "fiona@example.com",
  phone: "0607080947",
  team_id: 2,
  password: "password123",
  genre: "F"
})
Todolist.Users.create_user(%{
  firstname: "Alice",
  lastname: "Smith",
  address: "456 Avenue, Town",
  role: "Manager",
  mail: "alice@example.com",
  phone: "0607080910",
  team_id: nil,
  password: "securePwd123",
  genre: "F"
})
Todolist.Users.create_user(%{
  firstname: "Bob",
  lastname: "Johnson",
  address: "789 Road, Village",
  role: "User",
  mail: "bob@example.com",
  phone: "0607080912",
  team_id: 1,
  password: "safePwd456",
  genre: "N"
})
Todolist.Users.create_user(%{
  firstname: "Eva",
  lastname: "Williams",
  address: "101 Lane, County",
  role: "General Manager",
  mail: "eva@example.com",
  phone: "0607080913",
  team_id: nil,
  password: "newPwd789",
  genre: "F"
})
Todolist.Users.create_user(%{
  firstname: "Paul",
  lastname: "Gary",
  address: "156 Street, Foo",
  role: "User",
  mail: "paul@example.com",
  phone: "0607080945",
  team_id: 3,
  password: "password123",
  genre: "H"
})
Todolist.Users.create_user(%{
  firstname: "Steeve",
  lastname: "Klein",
  address: "145 Street, Bar",
  role: "User",
  mail: "steeve@example.com",
  phone: "0607080935",
  team_id: 3,
  password: "password123",
  genre: "H"
})

Todolist.Teams.create_team(%{
  name: "Sales",
  manager_id: 3
}
)

Todolist.Teams.create_team(%{
  name: "Marketing",
  manager_id: 5
}
)

Todolist.Teams.create_team(%{
  name: "Engineering",
  manager_id: 5
}
)

current_datetime = DateTime.utc_now()


Todolist.Timespents.create_timespent(%{
  description: "Task 2",
  date_start: DateTime.to_iso8601(current_datetime |> DateTime.add(-2, :day)) ,
  date_end: DateTime.to_iso8601(current_datetime |> DateTime.add(-1, :day)),
  user_id: 2
})

Todolist.Timespents.create_timespent(%{
  description: "Task 3",
  date_start: DateTime.to_iso8601(current_datetime |> DateTime.add(-3, :day)),
  date_end: DateTime.to_iso8601(current_datetime |> DateTime.add(-2, :day)),
  user_id: 3
})

# Set the user_id and initial date
user_id = 1
current_datetime = DateTime.utc_now() |> DateTime.truncate(:day)

# Loop for one week (7 days) starting from Monday
for day <- 0..6 do
  # Calculate the start and end times for the current day
  date_start = current_datetime |> DateTime.add(day, :day) |> DateTime.add(7, :hour)
  date_end = date_start |> DateTime.add(7, :hour)

  # Create a time spent entry
  timespent_params = %{
    description: "Work for user 1 on day #{day + 1}",
    date_start: DateTime.to_iso8601(date_start),
    date_end: DateTime.to_iso8601(date_end),
    user_id: user_id
  }

  # Insert the time spent entry into the database
  Todolist.Timespents.create_timespent(timespent_params)
end
