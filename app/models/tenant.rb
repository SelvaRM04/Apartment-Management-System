class Tenant < ApplicationRecord
    belongs_to :house
    has_secure_password
end
