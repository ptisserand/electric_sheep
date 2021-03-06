require 'mail'
require 'premailer'

module ElectricSheep
  module Notifiers
    class Email
      include Notifier

      register as: 'email'

      option :from, required: true
      option :to, required: true
      # Delivery method
      option :using, required: true
      # Delivery options
      option :with

      def notify!
        msg = Mail.new
        msg.from option(:from)
        msg.to option(:to)
        msg.subject subject
        msg.html_part = Mail::Part.new.tap do |part|
          part.content_type 'text/html; charset=UTF-8'
          part.body html_body
        end
        deliver(msg)
      end

      protected

      def subject
        if job.successful?
          "Backup successful: #{job.name}"
        else
          "BACKUP FAILED: #{job.name}"
        end
      end

      def html_body
        preflight Template.new('email.html')
          .render job: job,
                  assets_url: assets_url,
                  time: Time.now.getlocal,
                  timezone: Time.now.getlocal.zone,
                  hostname: `hostname`.chomp
      end

      def preflight(body)
        Premailer.new(body, with_html_string: true).to_inline_css
      end

      def deliver(msg)
        # Mail expects option keys as symbols
        msg.delivery_method option(:using), handle_options(option(:with))
        msg.deliver
      end

      def assets_url
        "http://assets.electricsheep.io/#{ElectricSheep::VERSION}/" \
          'notifiers/email'
      end

      def handle_options(options)
        return unless options
        options.each_with_object({}) do |(k, v), h|
          v = v.decrypt if v.respond_to?(:decrypt)
          h[k.to_sym] = v
        end
      end
    end
  end
end
