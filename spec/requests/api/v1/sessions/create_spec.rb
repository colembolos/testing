describe 'POST api/v1/users/sign_in', type: :request do
  subject { post new_user_session_path, params: params, as: :json }

  let(:password) { 'password' }
  let(:user) { create(:user, :confirmed, password: password) }
  let(:params) do
    {
      user:
        {
          email: user.email,
          password: password
        }
    }
  end

  context 'with correct params' do
    it_behaves_like 'there must not be a Set-Cookie in Header'
    it_behaves_like 'does not check authenticity token'

    context 'when the user is confirmed' do
      it 'returns success' do
        subject
        expect(response).to be_successful
      end

      it 'returns the user' do
        subject
        expect(json[:user][:id]).to eq(user.id)
        expect(json[:user][:email]).to eq(user.email)
        expect(json[:user][:uid]).to eq(user.uid)
        expect(json[:user][:provider]).to eq('email')
        expect(json[:user][:first_name]).to eq(user.first_name)
        expect(json[:user][:last_name]).to eq(user.last_name)
      end

      it 'returns a valid client and access token' do
        subject
        token = response.header['access-token']
        client = response.header['client']
        expect(user.reload.valid_token?(token, client)).to be_truthy
      end
    end

    context 'when the user is not confirmed' do
      before do
        user.update!(confirmed_at: nil)
      end

      it 'returns unauthorized' do
        subject
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error' do
        subject
        expect(json[:error]).to eq(
          "A confirmation email was sent to your account at '#{user.email}'. "\
          'You must follow the instructions in the email before your account can be activated'
        )
      end
    end

    context 'when the user has made many failed attempts' do
      before do
        user.lock_access!
        subject
      end

      it 'return locked error' do
        expect(response).to have_http_status(:unauthorized)
        expected_response = {
          error: 'Your account has been locked due to an excessive number of unsuccessful '\
                 "sign in attempts. Try again in #{Devise.unlock_in / 60} minutes"
        }.with_indifferent_access
        expect(json).to eq(expected_response)
      end
    end
  end

  context 'with incorrect params' do
    let(:params) do
      {
        user: {
          email: user.email,
          password: 'wrong_password!'
        }
      }
    end

    it 'return errors upon failure' do
      subject

      expect(response).to be_unauthorized
      expected_response = {
        error: 'Invalid login credentials. Please try again.'
      }.with_indifferent_access
      expect(json).to eq(expected_response)
    end
  end
end
