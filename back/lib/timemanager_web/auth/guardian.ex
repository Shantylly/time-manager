defmodule TodoListWeb.Auth.Guardian do
  use Guardian, otp_app: :timemanager
  alias Todolist.Users

  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_ , _) do
    {:error, :no_id_provided}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user!(id) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_subject_provided}
  end

  def auth(email,password) do
    case Users.get_user_by_email!(email) do
      nil -> {:error, :unauthorized}
      user ->
        case validate_password(password,user.password) do
          true -> create_token(user)
          false -> {:error, :unauthorized}
        end
    end
  end

  defp validate_password(password, hash_password) do
    Bcrypt.verify_pass(password,hash_password)
  end

  defp create_token(user) do
    {:ok, token, _claims} = encode_and_sign(user)
    {:ok, user, token}
  end
end
