class CatRentalRequest < ActiveRecord::Base
  validates :cat_id, :start_date, :end_date, :status, presence: true
  validate :overlapping_approved_requests

  belongs_to :cat,
    foreign_key: :cat_id,
    primary_key: :id,
    class_name: 'Cat'

  def overlapping_approved_requests
    if status == "APPROVED" && overlapping_requests.exists?(status: "APPROVED")
      errors[:request_id] << "The cat is already booked for that date."
    end
  end

  def overlapping_requests
    CatRentalRequest.where(cat_id: cat_id).where.not(id: id).
      where(<<-SQL, start_date: start_date, end_date: end_date)
        start_date BETWEEN start_date AND end_date
        OR end_date BETWEEN start_date AND end_date
      SQL
  end

  def approve!
    raise "Not Pending" unless self.status == "PENDING"
    transaction do
      self.status = "APPROVED"
      self.save!

      overlapping_pending_requests.update_all(status: 'DENIED')
    end
  end

  def overlapping_pending_requests
    overlapping_requests.where(status: "PENDING")
  end

  def deny!
    self.status = "DENIED"
  end
end
