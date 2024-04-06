# frozen_string_literal: true

module Metadata
  class Product
    include DocumentRecord

    field :product_id, type: String
    field :links, type: Hash

    validates :product_id, presence: true, uniqueness: { case_sensitive: false }
  end
end
