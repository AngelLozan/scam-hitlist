class IocPolicy < ApplicationPolicy
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


  def presigned?
    user.is_brand_protector?
  end

  def download_presigned?
    user.is_brand_protector?
  end

  def ca?
    user.is_brand_protector?
  end

  def show?
    true
  end

  def new?
    user.is_brand_protector?
  end

  def simple_create?
    true
  end

  def create?
   user.is_brand_protector?
  end

  def edit?
    update?
  end

  def update?
    user.is_brand_protector?
  end

  def destroy?
    user.is_brand_protector?
  end
end
