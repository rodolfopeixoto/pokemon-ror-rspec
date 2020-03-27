class Pokemon < ApplicationRecord

  scope :chosen_yesterday, -> do
    where(chosen_at: 1.day.ago.midnight..Time.zone.now.midnight)
  end

  def full_name
    "#{name} - #{id_national}" if name && id_national
  end
end
