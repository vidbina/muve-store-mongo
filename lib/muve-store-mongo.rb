require 'muve-store-mongo/version'
require 'muve'
require 'mongo'

module Muve
  module Store
    module Mongo
      require 'muve-store-mongo/errors'
      require 'muve-store-mongo/formatter'

      extend Muve::Store

      def self.create(resource, details)
        raise Muve::Error::InvalidAttribute, "Invalid create details" unless details.kind_of? Hash
        resource.database[resource.container].insert(details)
      end

      def self.fetch(resource, id, details={})
        # TODO: discover a solution that works for situations where database 
        # driver returns string keys as well as symbol keys
        raise Muve::Error::InvalidAttribute, "Invalid details" unless details.kind_of? Hash
        raise Muve::Error::InvalidQuery, "The id or details need to be set" if (id.nil? && details.empty?)
        id = ((BSON::ObjectId.from_string(id) if id.kind_of? String) or id)
        result = resource.database[resource.container].find_one(details.merge(_id: id))
        raise Muve::Error::NotFound, "#{resource} #{id} is not found" unless result
        result = Helper.symbolize_keys(result)
        result[:id] = result.delete(:_id)
        result
      end

      def self.find(resource, details={})
        raise Muve::Error::InvalidAttribute, "Invalid details" unless details.kind_of? Hash
        Enumerator.new do |result|
          resource.database[resource.container].find(details).each do |item|
            item = Helper.symbolize_keys(item)
            item[:id] = item.delete(:_id)
            result << item
          end
        end
      end

      def self.update(resource, id, details)
        raise Muve::Error::InvalidAttribute, "Invalid details" unless details.kind_of? Hash
        # TODO: raise error if details is not valid
        id = ((BSON::ObjectId.from_string(id) if id.kind_of? String) or id)
        resource.database[resource.container].find_and_modify(
          query: { _id: id },
          update: details
        )
      end

      def self.delete(resource, id, details={})
        raise Muve::Error::InvalidAttribute, "Invalid details" unless details.kind_of? Hash
        id = ((BSON::ObjectId.from_string(id) if id.kind_of? String) or id)
        details = details.merge(_id: id) if id
        resource.database[resource.container].remove(details)
      end

      # TODO: raise error if details is not a hash
      def self.count(resource, details={})
        raise Muve::Error::InvalidAttribute, "Invalid details" unless details.kind_of? Hash
        resource.database[resource.container].count(details)
      end

      def self.formatter
        Muve::Store::Mongo::Formatter
      end
    end
  end
end
