class Block < ApplicationRecord
    belongs_to :apartment
    has_many :houses, dependent: :destroy
end
