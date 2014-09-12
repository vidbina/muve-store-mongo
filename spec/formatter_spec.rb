require 'spec_helper'
require 'mongo'

describe 'Mongo Formatter' do
  let(:latitude) { Faker::Geolocation.lat }
  let(:longitude) { Faker::Geolocation.lng }
  let(:location) { Muve::Location.new(latitude: latitude, longitude: longitude) }
  let(:place) { Muve::Place.new(location: location, name: 'Somewhere') }
  let(:storeable) { { type: 'Place', coordinates: [ longitude, latitude ] } }

  before do
    # Muve.init(connection, database)
  end

  it { expect(Muve::Store::Mongo::Formatter.convert_to_storeable_object(location)).to eq({
    type: 'Place',
    coordinates: [longitude, latitude]
  }) }

  it { expect(
    Muve::Store::Mongo::Formatter.convert_from_storeable_object(storeable)
  ).to eq(Muve::Location.new(latitude: latitude, longitude: longitude)) }
end
