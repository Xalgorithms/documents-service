require_relative './apis/v1/actions'
require_relative './apis/v1/documents'

class AllAPIs < Grape::API
  mount APIs::V1::Actions
  mount APIs::V1::Documents
end
