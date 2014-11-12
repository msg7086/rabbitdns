module RabbitHouse
  class UserAPI < Grape::API
    resource :user do
      desc 'Create a user'
      params do
        requires :name, type: String, desc: 'Username'
        requires :email, type: String, desc: 'Email'
        requires :password, type: String, desc: 'Password'
      end
      post :create do
        u = User.where :email => params[:email]
        error! 'This email address is already used', 409 if u.size > 0
        u = User.new
        u.name = params[:name]
        u.email = params[:email]
        u.password = params[:password]
        u.save!
        "OK"
      end

      desc 'Authenticate a user'
      params do
        requires :email, type: String, desc: 'Email'
        requires :password, type: String, desc: 'Password'
      end
      post :auth do
        u = User.where :email => params[:email]
        error! 'Wrong credentials', 401 if u.size == 0
        u = u.first
        error! 'Wrong credentials', 401 if !u.valid_user?(params[:password])
        status 200
        return u.passkey
      end
    end
  end
end
