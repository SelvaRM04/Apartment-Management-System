class House < ApplicationRecord
    belongs_to :block
    belongs_to :owner
    has_one :tenant, dependent: :destroy
    has_one :security
    has_many :messages, dependent: :destroy
end
