class FormPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def home?
    true
  end

  def settings?
    true
  end

  def show
    user.is_brand_protector?
  end

  def new
    create?
  end

  def create
   user.is_brand_protector?
  end

  def edit
    update?
  end

  def update
    user.is_brand_protector?
  end

  def destroy
    user.is_brand_protector?
  end
end
