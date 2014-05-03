require File.dirname(__FILE__) + '/../test_helper'
require 'programitems_controller'

# Re-raise errors caught by the controller.
class ProgramitemsController; def rescue_action(e) raise e end; end

class ProgramitemsControllerTest < Test::Unit::TestCase
  fixtures :programitems

  def setup
    @controller = ProgramitemsController.new
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

    assert_not_nil assigns(:programitems)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:programitem)
    assert assigns(:programitem).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:programitem)
  end

  def test_create
    num_programitems = Programitem.count

    post :create, :programitem => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_programitems + 1, Programitem.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:programitem)
    assert assigns(:programitem).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Programitem.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Programitem.find(1)
    }
  end
end
