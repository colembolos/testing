describe UserDecorator do
  let(:user) { create(:user) }
  let(:decorated_user) { user.decorate }

  it 'returns same email' do
    expect(decorated_user.email).to eq(user.email)
  end

  describe '#minutes_to_unlock' do
    before { user.update!(locked_at: Time.zone.now - 15.minutes) }

    it 'returns 5 minutes' do
      expect(decorated_user.minutes_to_unlock).to eq(5)
    end
  end
end
