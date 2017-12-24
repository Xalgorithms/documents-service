require_relative './apis/v1/documents'

class APIs < Grape::API
  mount Documents::APIv1 => '/v1/documents'
end
