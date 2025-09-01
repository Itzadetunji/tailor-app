require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'validations' do
    it 'validates presence of name' do
      client = build(:client, name: '')
      expect(client).not_to be_valid
      expect(client.errors[:name]).to include("can't be blank")
    end
    
    it 'validates minimum length of name' do
      client = build(:client, name: 'A')
      expect(client).not_to be_valid
      expect(client.errors[:name]).to include("is too short (minimum is 2 characters)")
    end
    
    it 'validates presence of gender' do
      client = build(:client, gender: '')
      expect(client).not_to be_valid
      expect(client.errors[:gender]).to include("can't be blank")
    end
    
    it 'validates gender inclusion' do
      client = build(:client, gender: 'Other')
      expect(client).not_to be_valid
      expect(client.errors[:gender]).to include("is not included in the list")
    end
    
    it 'validates measurement_unit inclusion' do
      client = build(:client, measurement_unit: 'meters')
      expect(client).not_to be_valid
      expect(client.errors[:measurement_unit]).to include("is not included in the list")
    end
    
    it 'validates email format' do
      client = build(:client, email: 'invalid-email')
      expect(client).not_to be_valid
      expect(client.errors[:email]).to include("is invalid")
    end
    
    it 'validates email uniqueness' do
      create(:client, email: 'test@example.com')
      client = build(:client, email: 'test@example.com')
      expect(client).not_to be_valid
      expect(client.errors[:email]).to include("has already been taken")
    end
    
    it 'validates positive measurement values' do
      client = build(:client, chest: -10)
      expect(client).not_to be_valid
      expect(client.errors[:chest]).to include("must be greater than 0")
    end
  end
  
  describe 'measurement conversion' do
    context 'when measurement_unit is inches' do
      it 'converts measurements from inches to centimeters before saving' do
        client = create(:client, measurement_unit: 'inches', chest: 40.0)
        expect(client.chest).to eq(40.0 * 2.54)
      end
    end
    
    context 'when measurement_unit is centimeters' do
      it 'does not convert measurements' do
        client = create(:client, measurement_unit: 'centimeters', chest: 100.0)
        expect(client.chest).to eq(100.0)
      end
    end
  end
  
  describe 'scopes' do
    let!(:active_client) { create(:client) }
    let!(:trashed_client) { create(:client, :trashed) }
    
    it 'returns only active clients' do
      expect(Client.active).to include(active_client)
      expect(Client.active).not_to include(trashed_client)
    end
    
    it 'returns only trashed clients' do
      expect(Client.trashed).to include(trashed_client)
      expect(Client.trashed).not_to include(active_client)
    end
  end
  
  describe 'soft delete' do
    let(:client) { create(:client) }
    
    it 'marks client as trashed' do
      client.soft_delete!
      expect(client.reload.in_trash).to be true
    end
    
    it 'can restore trashed client' do
      client.soft_delete!
      client.restore!
      expect(client.reload.in_trash).to be false
    end
  end
  
  describe 'bulk soft delete' do
    let!(:clients) { create_list(:client, 3) }
    
    it 'marks multiple clients as trashed' do
      client_ids = clients.map(&:id)
      affected_count = Client.bulk_soft_delete(client_ids)
      
      expect(affected_count).to eq(3)
      clients.each do |client|
        expect(client.reload.in_trash).to be true
      end
    end
  end
  
  describe 'custom field values' do
    let(:client) { create(:client) }
    let(:custom_field) { create(:custom_field) }
    
    it 'can set custom field value' do
      client.set_custom_field_value(custom_field, 'test value')
      expect(client.custom_field_value(custom_field)).to eq('test value')
    end
    
    it 'updates existing custom field value' do
      client.set_custom_field_value(custom_field, 'initial value')
      client.set_custom_field_value(custom_field, 'updated value')
      expect(client.custom_field_value(custom_field)).to eq('updated value')
    end
  end
end
