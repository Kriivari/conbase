require File.dirname(__FILE__) + '/../test_helper'
require 'programgroups_controller'

# Re-raise errors caught by the controller.
class ProgramgroupsController; def rescue_action(e) raise e end; end

class ProgramgroupsControllerTest < Test::Unit::TestCase
  fixtures :programgroups

  def setup
    @controller = ProgramgroupsController.new
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

    assert_not_nil assigns(:programgroups)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:programgroup)
    assert assigns(:programgroup).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:programgroup)
  end

  def test_create
    num_programgroups = Programgroup.count

    post :create, :programgroup => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_programgroups + 1, Programgroup.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:programgroup)
    assert assigns(:programgroup).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Programgroup.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Programgroup.find(1)
    }
  end
end
