#
# Copyright (c) 2011-2025 TOConline S.A. All rights reserved.
#
#

require "sp/job/common"

module SP
  module Job
    module OtpValidation
      class OtpValidationDefinedOperation
        extend SP::Job::Common

        OPERATIONS_TO_VALIDATE = [{ tube: "open-banking-accounts-ops", actions: ["edit-account"] },
                                  { tube: "users-email-ops", actions: ["update"]}]

        def self.check_operation(job)
          OPERATIONS_TO_VALIDATE.any? do |op|
            op[:tube] == job[:tube] && op[:actions].include?(job[:action])
          end
        end
      end

      def valid_redis_otp?
        has_key = get_redis_otp_key()
        return !has_key.nil?
      end

      private

      def get_redis_otp_key
        key_to_check = build_otp_key_to_check()
        current_cluster.redis.get(key_to_check)
      end

      def build_otp_key_to_check
        access_token = thread_data.current_job[:access_token]
        logger.info("#{$config[:service_id]}:auth:2fa:verified:#{access_token}")
        "#{$config[:service_id]}:auth:2fa:verified:#{access_token}"
      end
    end
  end
end
