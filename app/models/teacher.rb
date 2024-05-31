class Teacher < ApplicationRecord
  after_save :set_nickname, if: -> { saved_change_to_name? || saved_change_to_bio? }

  has_one_attached :photo

  def nickname
    if super.blank?
      set_nickname
    else
      super
    end
  end

  def set_nickname
    client = OpenAI::Client.new
      chaptgpt_response = client.chat(parameters: {
        model: "gpt-3.5-turbo",
        messages: [{
          role: "user",
          content: "Give me a special nickname for teacher #{name} who has the bio: #{bio}. ONLY give me the nickname and none of your usual answers."}]
      })
      new_nickname = chaptgpt_response["choices"][0]["message"]["content"]
      update(nickname: new_nickname)
      return new_nickname
  end
end
