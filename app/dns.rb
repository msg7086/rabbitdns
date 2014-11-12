module RabbitHouse
  class DNS < Grape::API
    version 'v1', using: :header, vendor: 'RabbitHouse'
    format :json
    prefix :api
    helpers do
      def current_user
        @user ||= User.authorize! request.headers['X-Key']
      end
      def authenticate!
        error!('Unauthorized access', 401) unless current_user
      end
    end

    mount RabbitHouse::UserAPI
    mount RabbitHouse::DomainAPI
  end
end
