describe 'GET api/v1/users/confirmation', type: :request do
  let(:user) { create(:user) }

  subject { get user_confirmation_path, params: params, as: :json }

  context 'when params are correct' do
    let(:token) { Devise.friendly_token }
    let(:params) { { confirmation_token: token } }

    before do
      user.update!(confirmation_token: token, confirmation_sent_at: Time.now.utc)
    end

    it 'redirects to confirmation url' do
      expect(subject).to redirect_to(/#{ENV['FRONTEND_CONFIRM_SUCCESS_URL']}/)
    end

    it 'sets auth tokens' do
      expect { subject }.to change { user.reload.tokens }
    end

    it 'sends valid auth tokens' do
      subject
      params = URI(response['Location'])
               .query.split('&').map { |query| query.split('=') }
               .select { |param| %w[access-token client].include?(param[0]) }.to_h
      token = params['access-token']
      client = params['client']
      expect(user.reload.valid_token?(token, client)).to be_truthy
    end
  end

  context 'when params are incorrect' do
    let(:token) { 'FAKE' }
    let(:params) { { confirmation_token: token } }

    before do
      user.update!(
        confirmation_token: Devise.friendly_token,
        confirmation_sent_at: Time.now.utc
      )
    end

    it 'redirects to login' do
      expect(subject).to redirect_to(ENV['FRONTEND_LOGIN_URL'])
    end
  end
end
