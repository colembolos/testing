describe Api::V1::ConfirmationsController, type: :routing do
  describe 'routing' do
    it 'routes to #show' do
      expect(get: '/api/v1/users/confirmation').to route_to('api/v1/confirmations#show')
    end
  end
end
