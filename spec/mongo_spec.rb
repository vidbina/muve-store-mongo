require 'spec_helper'
require 'mongo'

describe 'Mongo Adaptor' do
  let(:connection) { Mongo::MongoClient.new }
  let(:database) { connection.db('muve_test') }
  let(:adaptor) { Muve::Store::Mongo }
  let(:id_of_stored_resource) { database['places'].insert(
    name: Faker::Venue.name
  ) }

  before do
    class Place
      attr_accessor :city, :street, :building, :name

      include Muve::Model

      def self.container
        'places'
      end
    end

    class MockCollection
      def self.insert(arg)
      end
    end

    class MockResource
      def self.database
        [ MockCollection ]
      end

      def self.container
        0
      end

      def self.collection
        'collection'
      end
    end

    Muve.init(connection, database)
  end
  
  it { expect { Muve::Store::Mongo.create(Place, 12) }.to raise_error(Muve::Error::InvalidAttribute) }
  it { expect { Muve::Store::Mongo.update(Place, 12, nil) }.to raise_error(Muve::Error::InvalidAttribute) }
  it { expect { Muve::Store::Mongo.delete(Place, 12, nil) }.to raise_error(Muve::Error::InvalidAttribute) }
  it { expect { Muve::Store::Mongo.count(Place, 12) }.to raise_error(Muve::Error::InvalidAttribute) }
  it { expect { Muve::Store::Mongo.count(Place, 12) }.to raise_error(Muve::Error::InvalidAttribute) }
  it { expect { Muve::Store::Mongo.find(Place, 12) }.to raise_error(Muve::Error::InvalidAttribute) }
  it { expect { Muve::Store::Mongo.fetch(Place, 12, nil) }.to raise_error(Muve::Error::InvalidAttribute) }

  it { expect(Muve::Store::Mongo.formatter).to eq(Muve::Store::Mongo::Formatter) }

  it 'writes model data to the store' do
    expect{
      Muve::Store::Mongo.create(Place, {
        name: Faker::Venue.name,
        city: Faker::Address.city,
        street: Faker::Address.street_name,
        building: Faker::Address.building_number
      })
    }.to change{database['places'].count}.by(1)
  end

  it 'counts the records in the datastore' do
    expect{
      database['places'].insert(
        name: "Willy Wonka's Chocolate Factory",
        street: "Chocolane 12",
        building: "8",
        city: "Confectionopolis"
      )
    }.to change{Muve::Store::Mongo.count(Place, {})}.by(1)
  end

  it 'writes modifications to the store' do
    new_name = Faker::Venue.name
    expect {
      adaptor.update(Place, id_of_stored_resource, { name: new_name })
    }.to change {
      database['places'].find_one(_id: id_of_stored_resource)['name']
    }.to(new_name)
  end

  it 'finds a resource from store' do
    expect(adaptor.get(Place, id_of_stored_resource)[:id]).to eq(id_of_stored_resource)
  end

  it 'finds multiple resources from store' do
    expect(adaptor.find(Place, {})).to be_a(Enumerable)
  end

  it 'removes a resource from the store' do
    id_of_resource_to_be_removed = id_of_stored_resource
    expect {
      adaptor.delete(Place, id_of_resource_to_be_removed)
    }.to change { database['places'].count }.by(-1)
  end

  it 'extracts a resource from every result in a multiple resource set' do
    adaptor.find(Place, {}).take(3).each do |result|
      attributes = result.keys.map{ |i| i.to_s }
      expect(attributes).to include('id', 'name')
    end
  end

  context "wired to handle model I/O" do
    before do
      Place.adaptor = adaptor
    end

    it {
      expect(adaptor).to receive(:find).with(Place, {})
      Place.where({}).count
    }

    it {
      expect_any_instance_of(Place).to receive(:populate).with(anything).once
      Place.where({}).take(1).each do |item|
        expect(item).to be_a_kind_of(Place)
      end
    }

    it {
      Muve::Place.adaptor = adaptor
      expect(adaptor).to receive(:create).with(Muve::Place, {
        name: 'Hell',
        location: { type: 'Place', coordinates: [6, 66] }
      })

      Muve::Place.new(
        name: 'Hell', 
        location: Muve::Location.new(latitude: 66, longitude: 6)
      ).save
    }

    it {
      Place.adaptor = adaptor
      expect(adaptor).to receive(:create).with(Muve::Place, {
        name: 'Hell',
        location: { type: 'Place', coordinates: [6, 66] }
      })

      Muve::Place.new(
        name: 'Hell', 
        location: Muve::Location.new(latitude: 66, longitude: 6)
      ).save
    }

    it {
      storeable_object = {
        name: 'Hell', 
        location: Muve::Location.new(latitude: 66, longitude: 6)
      }

      expect(MockCollection).to receive(:insert).with(storeable_object)

      Muve::Store::Mongo.create(MockResource, storeable_object)
    }
  end
end
