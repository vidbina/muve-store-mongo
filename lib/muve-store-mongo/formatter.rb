module Muve
  module Store
    module Mongo
      module Formatter
        extend Muve::Store::Formatter

        def self.convert_to_storeable_object(resource)
          return {
            type: 'Place',
            coordinates: [resource.longitude, resource.latitude]
          } if resource.kind_of? Muve::Location
          return resource.name if resource.kind_of? Muve::Traveller
          resource
        end

        def self.convert_from_storeable_object(storeable, klass=nil)
          if klass
            return {
              id: storeable[:id],
              name: storeable[:name],
              location: (Location.new({
                latitude: storeable[:location]["coordinates"][1],
                longitude: storeable[:location]["coordinates"][0]  
              }) if storeable[:location] && storeable[:location]["coordinates"])
            } if (klass < Muve::Place)
  
            return {
              id: storeable[:id],
              time: storeable[:time],
              traveller: Traveller.new(name: storeable[:traveller]),
              location: Location.new(
                latitude: storeable[:location]["coordinates"][1],
                longitude: storeable[:location]["coordinates"][0]
              )
            } if (klass < Muve::Movement)
          end

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
