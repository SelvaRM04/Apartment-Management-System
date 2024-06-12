class Owner < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    validates :email, presence: true, uniqueness: true
    has_many :houses, dependent: :destroy
    has_secure_password
end
