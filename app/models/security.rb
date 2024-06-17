class Security < ApplicationRecord
    validates :name, uniqueness: true
    validates :email, presence: true, uniqueness: true
    has_secure_password
    belongs_to :apartment
end
