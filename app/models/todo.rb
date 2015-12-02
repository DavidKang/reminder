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
    if due.nil?
      return "no-date"
    else
      return "yesterday" if due == Date.yesterday
      return "today" if due == Date.today
      return "tomorrow" if due == Date.tomorrow
      return "in-the-grave" if due < today
      return "in-the-future" if due > today
    end
  end

end
