class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true
  end

  def new?
    create?
  end

  def create?
    user.is_brand_protector?
  end

  def edit?
    update?
  end

  def update?
    true
  end

  def destroy?
    user.is_brand_protector?
  end

end
