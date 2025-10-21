# frozen_string_literal: true

namespace :data do
  desc "Fix orphaned approvals - reset excusals without approval records to pending"
  task fix_orphaned_approvals: :environment do
    puts "Fixing orphaned recurring excusals..."
    fixed_recurring = 0
    RecurringExcusal.where.not(status: 'pending').find_each do |recurring|
      if recurring.recurring_approval.nil?
        recurring.update(status: 'pending')
        fixed_recurring += 1
      end
    end
    puts "Fixed #{fixed_recurring} orphaned recurring excusals"

    puts "Fixing orphaned excusal requests..."
    fixed_requests = 0
    ExcusalRequest.where.not(status: 'pending').find_each do |request|
      if request.approval.nil?
        request.update(status: 'pending')
        fixed_requests += 1
      end
    end
    puts "Fixed #{fixed_requests} orphaned excusal requests"

    puts "Done!"
  end
end
