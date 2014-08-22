require "muve-store-mongo/version"
require "muve"

module Muve
  module Store
    module Mongo
      require 'mongo'

      extend Muve::Store

      def self.create(resource, details)
        raise MuveInvalidAttributes, "Invalid create details" unless details.kind_of? Hash
        resource.database[resource.container].insert(details)
      end

      def self.fetch(resource, id, details={})
        # TODO: discover a solution that works for situations where database 
        # driver returns string keys as well as symbol keys
        raise MuveInvalidAttributes, "Invalid details" unless details.kind_of? Hash
        result = resource.database[resource.container].find_one(details.merge(_id: id))
        result = Helper.symbolize_keys(result)
        result[:id] = result.delete(:_id)
        result
      end

      def self.find(resource, details={})
        raise MuveInvalidAttributes, "Invalid details" unless details.kind_of? Hash
        Enumerator.new do |result|
          resource.database[resource.container].find(details).each do |item|
            item = Helper.symbolize_keys(item)
            item[:id] = item.delete(:_id)
            result << item
          end
        end
      end

      def self.update(resource, id, details)
        raise MuveInvalidAttributes, "Invalid details" unless details.kind_of? Hash
        # TODO: raise error if details is not valid
        resource.database[resource.container].find_and_modify(
          query: { _id: id },
          update: details
        )
      end

      def self.delete(resource, id, details={})
        raise MuveInvalidAttributes, "Invalid details" unless details.kind_of? Hash
        details = details.merge(_id: id) if id
        resource.database[resource.container].remove(details)
      end

      # TODO: raise error if details is not a hash
      def self.count(resource, details={})
        raise MuveInvalidAttributes, "Invalid details" unless details.kind_of? Hash
        resource.database[resource.container].count(details)
      end
    end
  end
end
