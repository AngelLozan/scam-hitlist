# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :current_user, :record

  def initialize(current_user, record)
    @user = current_user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(current_user, scope)
      @user = current_user
      @scope = scope
    end

    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :current_user, :scope
  end
end
