require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)


PV_API = 'XXXXX'.freeze
PV_PROJECT_ID = XXXXX

CH_API = 'XXXXX'.freeze
CH_PROJECT_NAME = 'XXXX'.freeze

pv_client = TrackerApi::Client.new(token: PV_API)
pv = pv_client.project(PV_PROJECT_ID)

ch_client = Clubhouse::Client.new(api_key: CH_API)
ch = ch_client.project(name: CH_PROJECT_NAME)

pv.stories.each do |pstory|
  puts "#{pstory.id} - #{pstory.name}"

  result = ch.create_story(
    external_id: pstory.id.to_s,
    name: pstory.name,
    description: pstory.description&.to_s,
    story_type: (["feature","chore","bug"].include?(pstory.story_type) ? pstory.story_type : nil),
    labels: pstory.labels&.map{|l| {name: l.name} }
  )

  # create comments
  story = ch.story(id: result["id"])
  pstory.comments&.map do |pcomment|
    next if pcomment.text.blank?
    story.create_comment(text: pcomment.text)
  end
end

# update stories' requestor
# ch.stories.each do |story|
#   story.requested_by_id = "5ea213ab-4479-41bb-a312-6f2b9775f464"
# end
