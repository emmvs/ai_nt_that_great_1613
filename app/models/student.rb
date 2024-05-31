require "open-URI"

class Student < ApplicationRecord
  # Old Syntax
  # after_save :set_emoji, if: -> { saved_change_to_name? || saved_change_to_bio? }
  # New Syntax
  after_save if: -> { saved_change_to_name? || saved_change_to_bio? } do
    set_emoji
    set_nickname
    set_photo
  end

  def address
    Rails.cache.fetch("#{cache_key_with_version}/address", expires_in: 2.hours) do
      client = OpenAI::Client.new
        chaptgpt_response = client.chat(parameters: {
          model: "gpt-3.5-turbo",
          messages: [{
            role: "user",
            content: "Give me a random address for student #{name} who has the bio: #{bio}. ONLY give me the emoji and none of your usual answers."}]
        })
        new_emoji = chaptgpt_response["choices"][0]["message"]["content"]
        update(emoji: new_emoji)
        return new_emoji
    end
  end

  has_one_attached :photo

  def emoji
    if super.blank?
      set_emoji
    else
      super
    end
  end

  def nickname
    if super.blank?
      set_nickname
      puts "👻 SETTING NEW NICKNAME AHHHHHHHHHHHH"
    else
      super
    end
  end

  private

  def set_photo
    client = OpenAI::Client.new
    response = client.images.generate(parameters: {
      prompt: "An image of #{name} who has the bio of: #{bio}", size: "256x256"
    })

    url = response["data"][0]["url"]
    file =  URI.open(url)

    photo.purge if photo.attached?
    photo.attach(io: file, filename: "ai_generated_image.png", content_type: "image/png")
    return photo
  end

  def set_emoji
    # Uncomment for caching
    # Rails.cache.fetch("#{cache_key_with_version}/emoji", expires_in: 2.hours) do
    client = OpenAI::Client.new
      chaptgpt_response = client.chat(parameters: {
        model: "gpt-3.5-turbo",
        messages: [{
          role: "user",
          # BC we are in the model, we do not need instance variable, but either self.name or we can leave self out 
          content: "Give me a special emoji for student #{name} who has the bio: #{bio}. ONLY give me the emoji and none of your usual answers."}]
      })
      new_emoji = chaptgpt_response["choices"][0]["message"]["content"]
      update(emoji: new_emoji)
      return new_emoji
  end
  # end

  def set_nickname
    client = OpenAI::Client.new
      chaptgpt_response = client.chat(parameters: {
        model: "gpt-3.5-turbo",
        messages: [{
          role: "user",
          content: "Give me a special nickname for student #{name} who has the bio: #{bio}. ONLY give me the nickname and none of your usual answers."}]
      })
      new_nickname = chaptgpt_response["choices"][0]["message"]["content"]
      update(nickname: new_nickname)
      return new_nickname
  end
end
