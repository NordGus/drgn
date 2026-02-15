class Session::Recurring::ExpireOrphanJob < ApplicationJob
  queue_as :default
  limits_concurrency to: 1, key: :recurring_expire_orphans, duration: 1.minute, group: "SessionActions"

  def perform(batch_size: 100, force_expiration: false)
    # This implementation is not optimal, because it will load each session into memory, and also it does not enqueues
    # jobs in bulk, but is done this way to ensure all callbacks are executed for each job.
    Session.perishable.find_each(batch_size:) { |session| Session::ExpireJob.perform_later(session, force_expiration:) }

    return :only_perishable_sessions_expired unless force_expiration

    Session.non_perishable.find_each(batch_size:) { |session| Session::ExpireJob.perform_later(session, force_expiration:) }

    :all_sessions_expired
  end
end
