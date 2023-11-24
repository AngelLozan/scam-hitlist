class HealthPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def readiness?
    true
  end

  def liveness?
    true
  end

end
