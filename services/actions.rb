require 'active_support/core_ext/string'

module Services
  class Actions
    def self.invoke(scope, name, payload)
      default_fn = lambda do |o|
        { status: :action_not_found, reason: "action not found (name=#{name})" }
      end
      
      fn = valid_actions(scope).fetch(name, default_fn)
      fn.call(payload)
    end

    private

    def self.valid_actions(scope)
      Dir.glob("lib/actions/#{scope}/*.rb").inject({}) do |o, n|
        parts = Pathname(n).split
        mn = parts[1].basename('.rb').to_s
        mp = parts[0].join(mn).to_s

        require_relative "../#{mp}"
        cl = "Actions::#{scope.to_s.camelize}::#{mn.camelize}".constantize

        o.merge(mn => cl.method(:invoke))
      end
    end
  end
end
