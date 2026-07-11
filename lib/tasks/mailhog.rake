namespace :mailhog do
  desc "Start MailHog server"
  task :serve, :environment do
    unless Rails.env.development? || Rails.env.test?
      puts "+++ MailHog is only for development and test environments +++"
      exit(0)
    end

    puts "+++ Starting MailHog server +++"
    success = system "MailHog --auth-file=#{Rails.root.join(".mailhog", "auth-file")}"

    if success.nil? && $?.signaled? && $?.termsig == 2
      puts "+++ MailHog server stopped +++"
    end

  rescue Interrupt
    puts "\n+++ MailHog server stopped +++"
    exit(130)
  end

  desc "Configure MailHog"
  task :configure, :environment do
    unless Rails.env.development? || Rails.env.test?
      puts "+++ MailHog is only for development and test environments +++"
      exit(0)
    end

    auth_file_path = Rails.root.join(".mailhog", "auth-file")

    if File.exist?(auth_file_path)
      puts "MailHog already configured, skipping..."
    else
      puts "MailHog not configured, creating..."
      FileUtils.mkdir_p(Rails.root.join(".mailhog"))
      FileUtils.touch(auth_file_path)
      password = `MailHog bcrypt password`
      File.write(auth_file_path, "developer:#{password}")
      puts "MailHog configured!"
    end
  end
end