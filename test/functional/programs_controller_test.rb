require File.dirname(__FILE__) + '/../test_helper'
require 'programs_controller'

# Re-raise errors caught by the controller.
class ProgramsController; def rescue_action(e) raise e end; end

class ProgramsControllerTest < Test::Unit::TestCase
  fixtures :programs

  def setup
    @controller = ProgramsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:programs)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:program)
    assert assigns(:program).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:program)
  end

  def test_create
    num_programs = Program.count

    post :create, :program => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_programs + 1, Program.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:program)
    assert assigns(:program).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Program.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Program.find(1)
    }
  end
end
