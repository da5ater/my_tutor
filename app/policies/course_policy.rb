class CoursePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end

  def show?
    record.publicly_available? || user.present? && (record.user == user || user.has_role?(:admin) || record.bought?(user))
  end

  def enroll?
    user.present? && record.publicly_available? && !owner?
  end


  def edit?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner? || admin?
  end

  def approve?
    admin?
  end

  def new?
    @user.has_role?(:admin) || @user.has_role?(:teacher)
  end

  def create?
    @user.has_role?(:admin) || @user.has_role?(:teacher)
  end

  private

  def admin?
    user&.has_role?(:admin)
  end

  def owner?
    user.present? && record.user == user
  end
end
