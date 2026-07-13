require "test_helper"

class EnrollmentPolicyTest < ActiveSupport::TestCase
  test "the enrollment owner can edit and destroy their enrollment" do
    enrollment = enrollments(:one)
    policy = EnrollmentPolicy.new(enrollment.user, enrollment)

    assert policy.edit?
    assert policy.destroy?
  end

  test "an admin can destroy but cannot edit another user's enrollment review" do
    enrollment = enrollments(:one)
    admin = users(:two)
    admin.add_role(:admin)
    policy = EnrollmentPolicy.new(admin, enrollment)

    assert_not policy.edit?
    assert policy.destroy?
  end

  test "another user cannot edit or destroy an enrollment" do
    enrollment = enrollments(:one)
    other_user = users(:two)
    policy = EnrollmentPolicy.new(other_user, enrollment)

    assert_not policy.edit?
    assert_not policy.destroy?
  end
end
