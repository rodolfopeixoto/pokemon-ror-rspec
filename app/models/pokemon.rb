class Pokemon < ApplicationRecord
  def full_name
    "#{name} - #{id_national}" if name && id_national
  end
end
