# frozen_string_literal: true

require "dotenv"
require "pry"
require "smarter_csv"
require "tty-prompt"
require "httparty"

def delete_tags
  all_tags = []
  tags_path = "/api/v2/signup_tags?page[size]=100&access_token=#{@key}"

  while tags_path
    tags_response = HTTParty.get("https://#{@slug}.nationbuilder.com" + tags_path)
    all_tags += tags_response["data"]

    tags_path = tags_response.fetch("links", {}).fetch("next", nil)
  end

  @csv_data.each do |row|
    tag = row[:tag]
    tag_id = all_tags.find { |t| t["attributes"]["name"] == tag }&.fetch("id", nil)
    next unless tag_id

    puts "Deleting tag: #{tag}"

    HTTParty.delete("https://#{@slug}.nationbuilder.com/api/v2/signup_tags/#{tag_id}?access_token=#{@key}")
  end
end

prompt = TTY::Prompt.new

@slug = prompt.ask("What is your Nation slug?", default: "")
@key = prompt.ask("What is your API key?", default: "")
@filename = prompt.ask("What is the CSV filename you'd like to process.", default: "tags.csv")
@csv_data = SmarterCSV.process(@filename)

delete_tags
