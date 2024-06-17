class Admin < ApplicationRecord
    validates :name, uniqueness: true, presence: true 
    validates :email, uniqueness: true, presence: true
    has_secure_password
end
