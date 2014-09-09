module Muve
  module Store
    module Mongo
      module Formatter
        def self.extract(obj, fields)
          {}
        end

        def self.extract_location_from_field(obj, fieldname)
          loc = obj.send(fieldname)
          raise "Invalid resource for extract" unless loc.kind_of? Muve::Location
          return { type: 'Point', coordinates: [loc.longitude, loc.latitude] }
        end

        def self.convert_to_location(obj, fieldname)
          
        end

        def self.convert_to_storeable_object(resource)
          return {
            type: 'Place',
            coordinates: [resource.longitude, resource.latitude]
          } if resource.kind_of? Muve::Location
          resource
        end

        def self.convert_from_storeable_object(storeable)
          if storeable.kind_of? Hash
            if Helper.symbolize_keys(storeable).to_a.include? [:type, 'Place']
              Location.new(latitude: storeable[:coordinates][1], longitude: storeable[:coordinates][0]) if storeable[:coordinates]
            end
          end
        end
      end
    end
  end
end
