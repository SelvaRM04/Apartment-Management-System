class Apartment < ApplicationRecord
    has_many :blocks, dependent: :destroy
    has_one :security ,dependent: :destroy
end
