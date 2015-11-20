class Todo < ActiveRecord::Base
  include AASM

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

end
