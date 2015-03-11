#!/usr/bin/env ruby

require 'zermelo/records/redis_record'

require 'flapjack/data/validators/id_validator'

module Flapjack
  module Data
    class UnscheduledMaintenance

      include Zermelo::Records::RedisRecord
      include ActiveModel::Serializers::JSON
      self.include_root_in_json = false
      include Swagger::Blocks

      define_attributes :start_time => :timestamp,
                        :end_time   => :timestamp,
                        :summary    => :string

      belongs_to :check_by_start, :class_name => 'Flapjack::Data::Check',
        :inverse_of => :unscheduled_maintenances_by_start

      belongs_to :check_by_end, :class_name => 'Flapjack::Data::Check',
        :inverse_of => :unscheduled_maintenances_by_end

      before_validation :ensure_start_time

      validates :start_time, :presence => true
      validates :end_time, :presence => true

      validates_with Flapjack::Data::Validators::IdValidator

      def duration
        self.end_time - self.start_time
      end

      def check
        self.check_by_start
      end

      def check=(c)
        self.check_by_start = c
        self.check_by_end   = c
      end

      swagger_model :jsonapi_UnscheduledMaintenance do
        key :id, :jsonapi_UnscheduledMaintenance
        property :unscheduled_maintenances do
          key :type, :UnscheduledMaintenance
        end
      end

      swagger_model :jsonapi_UnscheduledMaintenances do
        key :id, :jsonapi_UnscheduledMaintenances
        property :unscheduled_maintenances do
          key :type, :array
          items do
            key :type, :UnscheduledMaintenance
          end
        end
      end

      swagger_model :UnscheduledMaintenance do
        key :id, :UnscheduledMaintenance
        key :required, [:start_time, :end_time]
        property :id do
          key :type, :string
        end
        property :start_time do
          key :type, :string
          key :format, :"date-time"
        end
        property :end_time do
          key :type, :string
          key :format, :"date-time"
        end
        property :links do
          key :"$ref", :UnscheduledMaintenanceLinks
        end
      end

      swagger_model :UnscheduledMaintenanceLinks do
        key :id, :UnscheduledMaintenanceLinks
        property :check do
          key :type, :string
        end
      end

      def self.jsonapi_type
        self.name.demodulize.underscore
      end

      def self.jsonapi_attributes
        [:start_time, :end_time, :summary]
      end

      def self.jsonapi_singular_associations
        [{:check_by_start => :check, :check_by_end => :check}]
      end

      def self.jsonapi_multiple_associations
        []
      end

      private

      def ensure_start_time
        self.start_time ||= Time.now
      end

    end
  end
end
