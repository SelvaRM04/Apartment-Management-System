class Tenant < ApplicationRecord
    belongs_to :house
    has_secure_password
    validates :name, uniqueness: true, presence: true
    validates :email, uniqueness: true, presence: true
end
