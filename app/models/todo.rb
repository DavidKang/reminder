class Todo < ActiveRecord::Base
  include AASM

  scope :pending,  -> { where(state: :started) }
  scope :finished, -> { where.not(state: :started) }

  aasm column: 'state' do
    state :started, initial: true
    state :closed

    event :done do
      transitions from: :started, to: :closed
    end

    event :reopen do
      transitions from: :closed, to: :started
    end
  end

  def when?
    today = Date.today
    prev_week = Date.today.prev_week
    return "YESTERDAY" if due == Date.yesterday
    return "TODAY" if due == Date.today
    return "TOMORROW" if due == Date.tomorrow
    return "LAST WEEK" if due > prev_week.beginning_of_week && due < prev_week.end_of_week
    return "THIS WEEK" if due > today.beginning_of_week && due <  today.end_of_week
    return "IN THE GRAVE" if due < today
    return "IN THE FUTURE" if due > today
  end

end
