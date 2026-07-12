class EnrollmentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
  end

  def index?
    @user.has_role?(:admin)
  end

  def show?
    @user.has_role?(:admin) || @record.user == @user
  end



  def update?
    @record.user == @user
  end

  def edit?
    @record.user == @user
  end

  def destroy?
    @record.user == @user
  end
end
