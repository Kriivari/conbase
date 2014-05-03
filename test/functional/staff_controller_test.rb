require File.dirname(__FILE__) + '/../test_helper'
require 'staff_controller'

# Re-raise errors caught by the controller.
class StaffController; def rescue_action(e) raise e end; end

class StaffControllerTest < Test::Unit::TestCase
  def setup
    @controller = StaffController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
