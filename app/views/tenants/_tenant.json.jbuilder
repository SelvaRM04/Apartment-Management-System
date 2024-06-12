json.extract! tenant, :id, :name, :email, :created_at, :updated_at
json.url tenant_url(tenant, format: :json)
