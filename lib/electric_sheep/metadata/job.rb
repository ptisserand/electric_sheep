module ElectricSheep
  module Metadata
    class Job < Base
      include Pipe
      include Monitor

      option :id, required: true
      option :description

      attr_reader :schedule, :starts_with

      def start_with!(resource)
        @starts_with = resource
      end

      def use_private_key!(key)
        @private_key=key
      end

      def private_key
        @private_key
      end

      def notifier(metadata)
        notifiers << metadata
      end

      def validate(config)
        queue.each do |step|
          unless step.validate(config)
            errors.add(:base, "Invalid step #{step.to_s}", step.errors)
          end
        end
        super
      end

      def schedule!(schedule)
        @schedule = schedule
      end

      def on_schedule(&block)
        if @schedule && @schedule.expired?
          @schedule.update!
          yield self
        end
      end

      def name
        description.nil? ? "#{id}" : "#{description} (#{id})"
      end

      def notifiers
        @notifiers ||= []
      end

    end
  end
end
