class SlackNotifierWorker
  include Sidekiq::Worker
  sidekiq_options queue: "high"

  def perform(todo)
    slack = Slack::Notifier.new "https://hooks.slack.com/services/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",
                                    username: 'reminder'
    todo = Todo.find(todo)
    slack.channel = "@#{todo.to}" if !todo.to.nil?
    slack.ping "#{todo.title}"
  end
end
