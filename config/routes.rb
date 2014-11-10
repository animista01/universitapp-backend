UniversitappBackend::Application.routes.draw do
  
  scope '/api' do
    post '/login', to: 'api#login'
    post '/homeworks', to: 'api#get_homeworks'
  end

end
