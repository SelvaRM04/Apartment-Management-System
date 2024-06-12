class Security < ApplicationRecord
    has_secure_password
    belongs_to :apartment
    validates :name, uniqueness: true
end
