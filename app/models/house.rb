class House < ApplicationRecord
    belongs_to :block
    has_one :owner
    has_one :tenant, dependent: :destroy
    has_one :security
    has_many :messages, dependent: :destroy
end
