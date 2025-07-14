require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      tag = Tag.new(name: 'test', count: 1)
      expect(tag).to be_valid
    end

    it 'is invalid without name' do
      tag = Tag.new(count: 1)
      expect(tag).to_not be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with duplicate name (case insensitive)' do
      Tag.create!(name: 'Test', count: 1)
      tag = Tag.new(name: 'test', count: 1)
      expect(tag).to_not be_valid
      expect(tag.errors[:name]).to include('has already been taken')
    end

    it 'is invalid with negative count' do
      tag = Tag.new(name: 'test', count: -1)
      expect(tag).to_not be_valid
      expect(tag.errors[:count]).to include('must be greater than or equal to 0')
    end
  end

  describe '.increment_count' do
    it 'creates a new tag with count 1' do
      expect {
        Tag.increment_count('NewTag')
      }.to change(Tag, :count).by(1)
      
      tag = Tag.find_by(name: 'newtag')
      expect(tag.count).to eq(1)
    end

    it 'increments existing tag count' do
      existing_tag = Tag.create!(name: 'existing', count: 2)
      
      Tag.increment_count('EXISTING')
      existing_tag.reload
      expect(existing_tag.count).to eq(3)
    end

    it 'normalizes tag names to lowercase' do
      Tag.increment_count('MixedCase')
      tag = Tag.find_by(name: 'mixedcase')
      expect(tag).to be_present
      expect(tag.count).to eq(1)
    end

    it 'ignores blank tag names' do
      expect {
        Tag.increment_count('')
        Tag.increment_count(nil)
        Tag.increment_count('   ')
      }.to_not change(Tag, :count)
    end
  end

  describe '.highest_count_tag' do
    it 'returns the tag with highest count' do
      tag1 = Tag.create!(name: 'low', count: 1)
      tag2 = Tag.create!(name: 'high', count: 5)
      tag3 = Tag.create!(name: 'medium', count: 3)
      
      expect(Tag.highest_count_tag).to eq(tag2)
    end

    it 'returns nil when no tags exist' do
      expect(Tag.highest_count_tag).to be_nil
    end
  end
end
