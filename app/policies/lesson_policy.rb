class LessonPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
  end

  def show?
    @user.has_role?(:admin) || @record.course.user_id == @user.id || @record.course.bought?(@user)
  end

  def create?
    @user.has_role?(:admin) || @record.course.user == @user
  end

  def new?
    @user.has_role?(:admin) || @record.course.user == @user
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
