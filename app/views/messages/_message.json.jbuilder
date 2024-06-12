json.extract! message, :id, :from_id, :from_desig, :to_id, :to_desig, :message, :created_at, :updated_at
json.url message_url(message, format: :json)
