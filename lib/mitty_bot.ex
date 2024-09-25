defmodule MittyBot do

  use Nostrum.Consumer

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!hi" ->
        Api.create_message(msg.channel_id, "Hello!")
      _ ->
        :ignore
      end
  end
end
