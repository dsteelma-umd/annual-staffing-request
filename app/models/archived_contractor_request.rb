class ArchivedContractorRequest < ContractorRequest
  self.table_name = 'archived_requests'
  class << self
    def policy_class
      ArchivedRequestPolicy
    end
  end
end