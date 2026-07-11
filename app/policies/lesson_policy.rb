class LessonPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
  end

  def show?
    @user.present?
  end

  def create?
    @user.has_role?(:admin) || @record.course.user == @user
  end

  def new?
    create?
  end

  def update?
    @user.has_role?(:admin) || @record.course.user == @user
  end

  def edit?
    update?
  end

  def destroy?
    @user.has_role?(:admin) || @record.course.user == @user
  end
end
