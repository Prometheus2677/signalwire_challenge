require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      ticket = Ticket.new(user_id: 1234, title: 'Test ticket')
      expect(ticket).to be_valid
    end

    it 'is invalid without user_id' do
      ticket = Ticket.new(title: 'Test ticket')
      expect(ticket).to_not be_valid
      expect(ticket.errors[:user_id]).to include("can't be blank")
    end

    it 'is invalid without title' do
      ticket = Ticket.new(user_id: 1234)
      expect(ticket).to_not be_valid
      expect(ticket.errors[:title]).to include("can't be blank")
    end

    it 'is invalid with non-numeric user_id' do
      ticket = Ticket.new(user_id: 'abc', title: 'Test ticket')
      expect(ticket).to_not be_valid
      expect(ticket.errors[:user_id]).to include('is not a number')
    end
  end

  describe 'callbacks' do
    it 'sets received_at on create' do
      freeze_time = Time.current
      allow(Time).to receive(:current).and_return(freeze_time)
      
      ticket = Ticket.create!(user_id: 1234, title: 'Test ticket')
      expect(ticket.received_at).to eq(freeze_time)
    end
  end
end
