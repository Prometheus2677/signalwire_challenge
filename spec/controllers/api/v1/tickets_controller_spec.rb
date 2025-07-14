require 'rails_helper'

RSpec.describe Api::V1::TicketsController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      {
        user_id: 1234,
        title: 'My title',
        tags: ['tag1', 'tag2']
      }
    end

    context 'with valid parameters' do
      it 'creates a ticket' do
        expect {
          post :create, params: valid_params
        }.to change(Ticket, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Ticket created successfully')
      end

      it 'increments tag counts' do
        post :create, params: valid_params
        
        tag1 = Tag.find_by(name: 'tag1')
        tag2 = Tag.find_by(name: 'tag2')
        
        expect(tag1.count).to eq(1)
        expect(tag2.count).to eq(1)
      end

      it 'works without tags' do
        params = valid_params.except(:tags)
        
        expect {
          post :create, params: params
        }.to change(Ticket, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end

      it 'works with empty tags array' do
        params = valid_params.merge(tags: [])
        
        expect {
          post :create, params: params
        }.to change(Ticket, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'returns 422 when user_id is missing' do
        params = valid_params.except(:user_id)
        
        post :create, params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('user_id is required')
      end

      it 'returns 422 when title is missing' do
        params = valid_params.except(:title)
        
        post :create, params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('title is required')
      end

      it 'returns 422 when user_id is not numeric' do
        params = valid_params.merge(user_id: 'abc')
        
        post :create, params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('user_id must be a number')
      end

      it 'returns 422 when tags is not an array' do
        params = valid_params.merge(tags: 'not_an_array')
        
        post :create, params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('tags must be an array')
      end

      it 'returns 422 when tags has 5 or more items' do
        params = valid_params.merge(tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'])
        
        post :create, params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include('tags must be fewer than 5')
      end
    end

    context 'webhook functionality' do
      before do
        allow(HTTParty).to receive(:post)
      end

      it 'sends webhook with highest count tag' do
        # Create some existing tags
        Tag.create!(name: 'existing1', count: 2)
        Tag.create!(name: 'existing2', count: 5)
        
        post :create, params: valid_params
        
        expect(HTTParty).to have_received(:post).with(
          anything,
          hash_including(
            body: hash_including(
              tag: 'existing2',
              count: 5
            ).to_json
          )
        )
      end

      it 'does not send webhook when no tags exist' do
        post :create, params: valid_params.except(:tags)
        
        # The webhook should still be sent for the tags created by this request
        expect(HTTParty).to have_received(:post)
      end
    end
  end
end
